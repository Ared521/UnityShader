using UnityEngine;
using UnityEditor;

namespace PaintIn3D
{
	[CustomPropertyDrawer(typeof(P3dGroup))]
	public partial class P3dGroup_Drawer : PropertyDrawer
	{
		public static void OnGUI(Rect position, P3dWindowBrushTip tip, GUIContent label)
		{
			tip.Group = Mathf.Clamp(tip.Group, 0, 31);

			var right  = position; right.xMin += EditorGUIUtility.labelWidth;
			var handle = "Group " + tip.Group;

			EditorGUI.LabelField(position, label);

			if (GUI.Button(right, handle, EditorStyles.popup) == true)
			{
				var menu = new GenericMenu();

				for (var i = 0; i < 32; i++)
				{
					var index   = i;
					var content = new GUIContent("Group " + i);
					var on      = tip.Group == index;

					menu.AddItem(content, on, () => { tip.Group = index; });
				}

				menu.DropDown(right);
			}
		}

		public static void OnGUI(Rect position, P3dWindowPaintableTexture paintableTexture)
		{
			paintableTexture.Group = Mathf.Clamp(paintableTexture.Group, 0, 31);

			var handle = new GUIContent("Group " + paintableTexture.Group, "If you're painting multiple textures at the same time, you can put them on separate groups so only one brush can paint on it.");

			if (GUI.Button(position, handle, EditorStyles.popup) == true)
			{
				var menu = new GenericMenu();

				for (var i = 0; i < 32; i++)
				{
					var index   = i;
					var content = new GUIContent("Group " + i);
					var on      = paintableTexture.Group == index;

					menu.AddItem(content, on, () => { paintableTexture.Group = index; });
				}

				menu.DropDown(position);
			}
		}

		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			var sObj = property.serializedObject;
			var sPro = property.FindPropertyRelative("index");

			if (sPro.intValue < 0 || sPro.intValue > 31)
			{
				sPro.intValue = Mathf.Clamp(sPro.intValue, 0, 31);

				sObj.ApplyModifiedProperties();
			}

			var right  = position; right.xMin += EditorGUIUtility.labelWidth;
			var handle = "Group " + sPro.intValue;

			EditorGUI.LabelField(position, label);

			if (GUI.Button(right, handle, EditorStyles.popup) == true)
			{
				var menu = new GenericMenu();

				for (var i = 0; i < 32; i++)
				{
					var index   = i;
					var content = new GUIContent("Group " + i);
					var on      = sPro.intValue == index;

					menu.AddItem(content, on, () => { sPro.intValue = index; sObj.ApplyModifiedProperties(); });
				}

				menu.DropDown(right);
			}
		}
	}
}