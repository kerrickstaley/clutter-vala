/*
 * Clutter.
 *
 * An OpenGL based 'interactive canvas' library.
 *
 * Authored By Matthew Allum  <mallum@openedhand.com>
 *
 * Copyright (C) 2007 OpenedHand
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/**
 * SECTION:clutter-behaviour-rotate
 * @short_description: A behaviour class to rotate actors
 *
 * A #ClutterBehaviourRotate rotate actors between a starting and ending
 * angle on a given axis.
 *
 * The #ClutterBehaviourRotate is available since version 0.4.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "clutter-actor.h"
#include "clutter-behaviour.h"
#include "clutter-main.h"
#include "clutter-fixed.h"
#include "clutter-behaviour-rotate.h"
#include "clutter-enum-types.h"
#include "clutter-private.h"
#include "clutter-debug.h"

#include <math.h>

G_DEFINE_TYPE (ClutterBehaviourRotate,
               clutter_behaviour_rotate,
               CLUTTER_TYPE_BEHAVIOUR);

struct _ClutterBehaviourRotatePrivate
{
  ClutterFixed angle_begin;
  ClutterFixed angle_end;

  ClutterRotateAxis axis;
  ClutterRotateDirection direction;
  gint center_x, center_y, center_z;
};

#define CLUTTER_BEHAVIOUR_ROTATE_GET_PRIVATE(obj) \
        (G_TYPE_INSTANCE_GET_PRIVATE ((obj), \
         CLUTTER_TYPE_BEHAVIOUR_ROTATE, \
         ClutterBehaviourRotatePrivate))

enum
{
  PROP_0,

  PROP_ANGLE_BEGIN,
  PROP_ANGLE_END,
  PROP_AXIS,
  PROP_DIRECTION,
  PROP_CENTER_X,
  PROP_CENTER_Y,
  PROP_CENTER_Z
};

static void 
alpha_notify_foreach (ClutterBehaviour *behaviour,
		      ClutterActor     *actor,
		      gpointer          data)
{
  ClutterFixed                   angle;
  ClutterBehaviourRotate        *rotate_behaviour;
  ClutterBehaviourRotatePrivate *priv;

  rotate_behaviour = CLUTTER_BEHAVIOUR_ROTATE (behaviour);
  priv = rotate_behaviour->priv;

  angle = GPOINTER_TO_UINT(data);

  switch (priv->axis)
    {
    case CLUTTER_X_AXIS:
      clutter_actor_rotate_xx (actor,
			       angle,
			       priv->center_y, priv->center_z);
      break;
    case CLUTTER_Y_AXIS:
      clutter_actor_rotate_yx (actor,
			       angle,
			       priv->center_x, priv->center_z);
      break;
    case CLUTTER_Z_AXIS:
      clutter_actor_rotate_zx (actor,
			       angle,
			       priv->center_x, priv->center_y);
      break;
    }
}

static void
clutter_behaviour_rotate_alpha_notify (ClutterBehaviour *behaviour,
                                       guint32           alpha_value)
{
  ClutterFixed factor, angle, diff;
  ClutterBehaviourRotate *rotate_behaviour;
  ClutterBehaviourRotatePrivate *priv;

  rotate_behaviour = CLUTTER_BEHAVIOUR_ROTATE (behaviour);
  priv = rotate_behaviour->priv;

  factor = CLUTTER_INT_TO_FIXED (alpha_value) / CLUTTER_ALPHA_MAX_ALPHA;
  angle = 0;
  
  switch (priv->direction)
    {
    case CLUTTER_ROTATE_CW:
      if (priv->angle_end >= priv->angle_begin)
	{
	  angle = CLUTTER_FIXED_MUL (factor, 
				     (priv->angle_end - priv->angle_begin));
	  angle += priv->angle_begin;
	}
      else
	{
	  /* Work out the angular length of the arch represented by the
	   * end angle in CCW direction
	   */
	  if (priv->angle_end > CLUTTER_INT_TO_FIXED(360))
	    {
	      ClutterFixed rounds, a1, a2;

	      rounds = priv->angle_begin / 360;
	      a1 = rounds * 360;
	      a2 = CLUTTER_INT_TO_FIXED(360) - (priv->angle_begin - a1);

	      diff = a1 + a2 + priv->angle_end;
	    }
	  else
	    {
	      diff = CLUTTER_INT_TO_FIXED(360) 
		        - priv->angle_begin + priv->angle_end;
	    }
      
	  angle = CLUTTER_FIXED_MUL (diff, factor);
	  angle += priv->angle_begin;
	}
      break;
    case CLUTTER_ROTATE_CCW:
      if (priv->angle_end <= priv->angle_begin)
	{
	  angle = CLUTTER_FIXED_MUL (factor, 
				     (priv->angle_begin - priv->angle_end));
	  angle += priv->angle_end;
	}
      else
	{
	  /* Work out the angular length of the arch represented by the
	   * end angle in CCW direction
	   */
	  if (priv->angle_end > CLUTTER_INT_TO_FIXED(360))
	    {
	      ClutterFixed rounds, a1, a2;

	      rounds = priv->angle_begin / 360;
	      a1 = rounds * 360;
	      a2 = CLUTTER_INT_TO_FIXED(360) - (priv->angle_end - a1);

	      diff = a1 + a2 + priv->angle_begin;
	    }
	  else
	    {
	      diff = CLUTTER_INT_TO_FIXED(360) 
		       - priv->angle_end + priv->angle_begin;
	    }
	  angle = priv->angle_begin - CLUTTER_FIXED_MUL (diff, factor);
	}
      break;
    }

  clutter_behaviour_actors_foreach (behaviour,
				    alpha_notify_foreach,
				    GUINT_TO_POINTER ((guint)angle));
}

static void
clutter_behaviour_rotate_set_property (GObject      *gobject,
                                       guint         prop_id,
                                       const GValue *value,
                                       GParamSpec   *pspec)
{
  ClutterBehaviourRotate *rotate;
  ClutterBehaviourRotatePrivate *priv;

  rotate = CLUTTER_BEHAVIOUR_ROTATE (gobject);
  priv = rotate->priv;

  switch (prop_id)
    {
    case PROP_ANGLE_BEGIN:
      priv->angle_begin = CLUTTER_FLOAT_TO_FIXED (g_value_get_double (value));
      break;
    case PROP_ANGLE_END:
      priv->angle_end = CLUTTER_FLOAT_TO_FIXED (g_value_get_double (value));
      break;
    case PROP_AXIS:
      priv->axis = g_value_get_enum (value);
      break;
    case PROP_DIRECTION:
      priv->direction = g_value_get_enum (value);
      break;
    case PROP_CENTER_X:
      clutter_behaviour_rotate_set_center (rotate,
					   g_value_get_int (value),
					   priv->center_y,
					   priv->center_z);
      break;
    case PROP_CENTER_Y:
      clutter_behaviour_rotate_set_center (rotate,
					   priv->center_x,
					   g_value_get_int (value),
					   priv->center_z);
      break;
    case PROP_CENTER_Z:
      clutter_behaviour_rotate_set_center (rotate,
					   priv->center_x,
					   priv->center_y,
					   g_value_get_int (value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (gobject, prop_id, pspec);
      break;
    }
}

static void
clutter_behaviour_rotate_get_property (GObject    *gobject,
                                       guint       prop_id,
                                       GValue     *value,
                                       GParamSpec *pspec)
{
  ClutterBehaviourRotatePrivate *priv;

  priv = CLUTTER_BEHAVIOUR_ROTATE (gobject)->priv;

  switch (prop_id)
    {
    case PROP_ANGLE_BEGIN:
      g_value_set_double (value, CLUTTER_FIXED_TO_DOUBLE (priv->angle_begin));
      break;
    case PROP_ANGLE_END:
      g_value_set_double (value, CLUTTER_FIXED_TO_DOUBLE (priv->angle_end));
      break;
    case PROP_AXIS:
      g_value_set_enum (value, priv->axis);
      break;
    case PROP_DIRECTION:
      g_value_set_enum (value, priv->direction);
      break;
    case PROP_CENTER_X:
      g_value_set_int (value, priv->center_x);
      break;
    case PROP_CENTER_Y:
      g_value_set_int (value, priv->center_y);
      break;
    case PROP_CENTER_Z:
      g_value_set_int (value, priv->center_z);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (gobject, prop_id, pspec);
      break;
    }
}

static void
clutter_behaviour_rotate_class_init (ClutterBehaviourRotateClass *klass)
{
  GObjectClass *gobject_class = G_OBJECT_CLASS (klass);
  ClutterBehaviourClass *behaviour_class = CLUTTER_BEHAVIOUR_CLASS (klass);

  gobject_class->set_property = clutter_behaviour_rotate_set_property;
  gobject_class->get_property = clutter_behaviour_rotate_get_property;

  behaviour_class->alpha_notify = clutter_behaviour_rotate_alpha_notify;

  /**
   * ClutterBehaviourRotate:angle-begin:
   *
   * The initial angle from whence the rotation should begin.
   *
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_ANGLE_BEGIN,
                                   g_param_spec_double ("angle-begin",
                                                        "Angle Begin",
                                                        "Initial angle",
                                                        0.0,
                                                        CLUTTER_ANGLE_MAX_DEG,
                                                        0.0,
                                                        CLUTTER_PARAM_READWRITE));
  /**
   * ClutterBehaviourRotate:angle-end:
   *
   * The final angle to where the rotation should end.
   * 
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_ANGLE_END,
                                   g_param_spec_double ("angle-end",
                                                        "Angle End",
                                                        "Final angle",
                                                        0.0,
                                                        CLUTTER_ANGLE_MAX_DEG,
                                                        360.0,
                                                        CLUTTER_PARAM_READWRITE));
  /**
   * ClutterBehaviourRotate:axis:
   *
   * The axis of rotation.
   *
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_AXIS,
                                   g_param_spec_enum ("axis",
                                                      "Axis",
                                                      "Axis of rotation",
                                                      CLUTTER_TYPE_ROTATE_AXIS,
                                                      CLUTTER_Z_AXIS,
                                                      CLUTTER_PARAM_READWRITE));
  /**
   * ClutterBehaviourRotate:direction:
   *
   * The direction of the rotation.
   *
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_DIRECTION,
                                   g_param_spec_enum ("direction",
                                                      "Direction",
                                                      "Direction of rotation",
                                                      CLUTTER_TYPE_ROTATE_DIRECTION,
                                                      CLUTTER_ROTATE_CW,
                                                      CLUTTER_PARAM_READWRITE));
  /**
   * ClutterBehaviourRotate:center-x:
   *
   * The x center of rotation. 
   *
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_CENTER_X,
                                   g_param_spec_int ("center-x",
                                                     "Center-X",
                                                     "X center of rotation",
                                                     -G_MAXINT, G_MAXINT,
                                                     0,
                                                     CLUTTER_PARAM_READWRITE));

  /**
   * ClutterBehaviourRotate:center-y:
   *
   * The y center of rotation. 
   *
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_CENTER_Y,
                                   g_param_spec_int ("center-y",
                                                     "Center-Y",
                                                     "Y center of rotation",
                                                     -G_MAXINT, G_MAXINT,
                                                     0,
                                                     CLUTTER_PARAM_READWRITE));
  /**
   * ClutterBehaviourRotate:center-z:
   *
   * The z center of rotation. 
   *
   * Since: 0.4
   */
  g_object_class_install_property (gobject_class,
                                   PROP_CENTER_Z,
                                   g_param_spec_int ("center-z",
                                                     "Center-Z",
                                                     "Z center of rotation",
                                                     -G_MAXINT, G_MAXINT,
                                                     0,
                                                     CLUTTER_PARAM_READWRITE));

  g_type_class_add_private (klass, sizeof (ClutterBehaviourRotatePrivate));
}

static void
clutter_behaviour_rotate_init (ClutterBehaviourRotate *rotate)
{
  ClutterBehaviourRotatePrivate *priv;

  rotate->priv = priv = CLUTTER_BEHAVIOUR_ROTATE_GET_PRIVATE (rotate);

  priv->angle_begin = CLUTTER_FLOAT_TO_FIXED (0.0);
  priv->angle_end = CLUTTER_FLOAT_TO_FIXED (360.0);
  priv->axis = CLUTTER_Z_AXIS;
  priv->direction = CLUTTER_ROTATE_CW;
  priv->center_x = priv->center_y = priv->center_z = 0;
}

/**
 * clutter_behaviour_rotate_new:
 * @alpha: a #ClutterAlpha, or %NULL
 * @axis: the rotation axis
 * @direction: the rotation direction
 * @angle_begin: the starting angle
 * @angle_end: the final angle
 *
 * Creates a new #ClutterBehaviourRotate. This behaviour will rotate actors
 * bound to it on @axis, following @direction, between @angle_begin and
 * @angle_end.
 *
 * Return value: the newly created #ClutterBehaviourRotate.
 *
 * Since: 0.4
 */
ClutterBehaviour *
clutter_behaviour_rotate_new (ClutterAlpha           *alpha,
                              ClutterRotateAxis       axis,
                              ClutterRotateDirection  direction,
                              gdouble                 angle_begin,
                              gdouble                 angle_end)
{
  return clutter_behaviour_rotate_newx (alpha, axis, direction,
                                        CLUTTER_FLOAT_TO_FIXED (angle_begin),
                                        CLUTTER_FLOAT_TO_FIXED (angle_end));
}

/**
 * clutter_behaviour_rotate_newx:
 * @alpha: a #ClutterAlpha or %NULL
 * @axis: the rotation axis
 * @direction: the rotation direction
 * @angle_begin: the starting angle, in fixed point notation
 * @angle_end: the final angle, in fixed point notation
 *
 * Creates a new #ClutterBehaviourRotate. This is the fixed point version
 * of clutter_behaviour_rotate_new().
 *
 * Return value: the newly created #ClutterBehaviourRotate.
 *
 * Since: 0.4
 */
ClutterBehaviour *
clutter_behaviour_rotate_newx (ClutterAlpha           *alpha,
                               ClutterRotateAxis       axis,
                               ClutterRotateDirection  direction,
                               ClutterFixed            angle_begin,
                               ClutterFixed            angle_end)
{
  ClutterBehaviour *retval;
  ClutterBehaviourRotatePrivate *priv;

  retval = g_object_new (CLUTTER_TYPE_BEHAVIOUR_ROTATE,
                         "alpha", alpha,
                         "axis", axis,
                         "direction", direction,
                         NULL);

  priv = CLUTTER_BEHAVIOUR_ROTATE_GET_PRIVATE (retval);
  priv->angle_begin = angle_begin;
  priv->angle_end = angle_end;

  return retval;
}

/**
 * clutter_behaviour_rotate_get_axis:
 * @rotate: a #ClutterBehaviourRotate
 *
 * Retrieves the #ClutterRotateAxis used by the rotate behaviour.
 *
 * Return value: the rotation axis
 *
 * Since: 0.4
 */
ClutterRotateAxis
clutter_behaviour_rotate_get_axis (ClutterBehaviourRotate *rotate)
{
  g_return_val_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate), CLUTTER_Z_AXIS);

  return rotate->priv->axis;
}

/**
 * clutter_behaviour_rotate_set_axis:
 * @rotate: a #ClutterBehaviourRotate
 * @axis: a #ClutterRotateAxis
 *
 * Sets the axis used by the rotate behaviour.
 *
 * Since: 0.4
 */
void
clutter_behaviour_rotate_set_axis (ClutterBehaviourRotate *rotate,
                                   ClutterRotateAxis       axis)
{
  ClutterBehaviourRotatePrivate *priv;

  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  priv = rotate->priv;

  if (priv->axis != axis)
    {
      g_object_ref (rotate);

      priv->axis = axis;

      g_object_notify (G_OBJECT (rotate), "axis");
      g_object_unref (rotate);
    }
}

/**
 * clutter_behaviour_rotate_get_direction:
 * @rotate: a #ClutterBehaviourRotate
 *
 * Retrieves the #ClutterRotateDirection used by the rotate behaviour.
 *
 * Return value: the rotation direction
 *
 * Since: 0.4
 */
ClutterRotateDirection
clutter_behaviour_rotate_get_direction (ClutterBehaviourRotate *rotate)
{
  g_return_val_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate),
                        CLUTTER_ROTATE_CW);

  return rotate->priv->direction;
}

/**
 * clutter_behaviour_rotate_set_direction:
 * @rotate: a #ClutterBehaviourRotate
 * @direction: the rotation direction
 *
 * Sets the rotation direction used by the rotate behaviour.
 *
 * Since: 0.4
 */
void
clutter_behaviour_rotate_set_direction (ClutterBehaviourRotate *rotate,
                                        ClutterRotateDirection  direction)
{
  ClutterBehaviourRotatePrivate *priv;

  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  priv = rotate->priv;

  if (priv->direction != direction)
    {
      g_object_ref (rotate);

      priv->direction = direction;

      g_object_notify (G_OBJECT (rotate), "direction");
      g_object_unref (rotate);
    }
}

/**
 * clutter_behaviour_rotate_get_bounds:
 * @rotate: a #ClutterBehaviourRotate
 * @angle_begin: return value for the initial angle
 * @angle_end: return value for the final angle
 *
 * Retrieves the rotation boundaries of the rotate behaviour.
 *
 * Since: 0.4
 */
void
clutter_behaviour_rotate_get_bounds (ClutterBehaviourRotate *rotate,
                                     gdouble                *angle_begin,
                                     gdouble                *angle_end)
{
  ClutterBehaviourRotatePrivate *priv;

  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  priv = rotate->priv;

  if (angle_begin)
    *angle_begin = CLUTTER_FIXED_TO_DOUBLE (priv->angle_begin);

  if (angle_end)
    *angle_end = CLUTTER_FIXED_TO_DOUBLE (priv->angle_end);
}

void
clutter_behaviour_rotate_set_bounds (ClutterBehaviourRotate *rotate,
                                     gdouble                 angle_begin,
                                     gdouble                 angle_end)
{
  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  clutter_behaviour_rotate_set_boundsx (rotate,
                                        CLUTTER_FLOAT_TO_FIXED (angle_begin),
                                        CLUTTER_FLOAT_TO_FIXED (angle_end));
}

/**
 * clutter_behaviour_rotate_get_bounds:
 * @rotate: a #ClutterBehaviourRotate
 * @angle_begin: return value for the initial angle
 * @angle_end: return value for the final angle
 *
 * Retrieves the rotation boundaries of the rotate behaviour. This is
 * the fixed point notation version of clutter_behaviour_rotate_get_bounds().
 *
 * Since: 0.4
 */
void
clutter_behaviour_rotate_get_boundsx (ClutterBehaviourRotate *rotate,
                                      ClutterFixed           *angle_begin,
                                      ClutterFixed           *angle_end)
{
  ClutterBehaviourRotatePrivate *priv;
  
  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));
  
  priv = rotate->priv;

  if (angle_begin);
    *angle_begin = priv->angle_begin;

  if (angle_end)
    *angle_end = priv->angle_end;
}

void
clutter_behaviour_rotate_set_boundsx (ClutterBehaviourRotate *rotate,
                                      ClutterFixed            angle_begin,
                                      ClutterFixed            angle_end)
{
  ClutterBehaviourRotatePrivate *priv;
  
  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  priv = rotate->priv;

  g_object_ref (rotate);
  g_object_freeze_notify (G_OBJECT (rotate));

  if (priv->angle_begin != angle_begin)
    {
      priv->angle_begin = angle_begin;

      g_object_notify (G_OBJECT (rotate), "angle-begin");
    }

  if (priv->angle_end != angle_end)
    {
      priv->angle_end = angle_end;

      g_object_notify (G_OBJECT (rotate), "angle-end");
    }

  g_object_thaw_notify (G_OBJECT (rotate));
  g_object_unref (rotate);
}

/**
 * clutter_behaviour_rotate_set_center:
 * @rotate: a #ClutterBehaviourRotate
 * @x: X axis center of rotation
 * @y: Y axis center of rotation
 * @z: Z axis center of rotation
 *
 * Sets the center of rotation. The coordinates are relative to the plane
 * normal to the rotation axis set with clutter_behaviour_rotate_set_axis().
 *
 * Since: 0.4
 */
void
clutter_behaviour_rotate_set_center (ClutterBehaviourRotate *rotate,
				     gint                    x,
				     gint                    y,
				     gint                    z)
{
  ClutterBehaviourRotatePrivate *priv;

  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  priv = rotate->priv;

  if (priv->center_x != x)
    {
      priv->center_x = x;
      g_object_notify (G_OBJECT (rotate), "center-x");
    }

  if (priv->center_y != y)
    {
      priv->center_y = y;
      g_object_notify (G_OBJECT (rotate), "center-y");
    }

  if (priv->center_z != z)
    {
      priv->center_z = z;
      g_object_notify (G_OBJECT (rotate), "center-z");
    }
}

/**
 * clutter_behaviour_rotate_get_center:
 * @rotate: a #ClutterBehaviourRotate
 * @x: return location for the X center of rotation
 * @y: return location for the Y center of rotation
 * @z: return location for the Z center of rotation
 *
 * Retrieves the center of rotation set using
 * clutter_behaviour_rotate_set_center().
 *
 * Since: 0.4
 */
void
clutter_behaviour_rotate_get_center (ClutterBehaviourRotate *rotate,
				     gint                   *x,
				     gint                   *y,
				     gint                   *z)
{
  ClutterBehaviourRotatePrivate *priv;

  g_return_if_fail (CLUTTER_IS_BEHAVIOUR_ROTATE (rotate));

  priv = rotate->priv;

  if (x)
    *x = priv->center_x;
  if (y)
    *y = priv->center_y;
  if (z)
    *z = priv->center_x;
}
