using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;

namespace PaintIn3D
{
	[CustomPropertyDrawer(typeof(P3dGroupMask))]
	public class P3dGroupMask_Drawer : PropertyDrawer
	{
		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			var sObj   = property.serializedObject;
			var sPro   = property.FindPropertyRelative("mask");
			var right  = position; right.xMin += EditorGUIUtility.labelWidth;
			var handle = default(string);

			EditorGUI.LabelField(position, property.displayName);

			if (sPro.intValue == 0)
			{
				handle = "Nothing";
			}
			else if (sPro.intValue == -1)
			{
				handle = "Everything";
			}
			else
			{
				//handle = "Mixed ...";
				var total = 0;

				for (var i = 0; i < 32; i++)
				{
					var on = P3dHelper.IndexInMask(i, sPro.intValue);

					if (on == true)
					{
						if (total == 0)
						{
							handle = "Group " + i;
						}
						else
						{
							handle += ", Group " + i;
						}

						total += 1;
					}
				}
			}

			if (GUI.Button(right, handle, EditorStyles.popup) == true)
			{
				var menu = new GenericMenu();

				menu.AddItem(new GUIContent("Nothing"), sPro.intValue == 0, () => { sPro.intValue = 0; sObj.ApplyModifiedProperties(); });

				menu.AddItem(new GUIContent("Everything"), sPro.intValue == -1, () => { sPro.intValue = -1; sObj.ApplyModifiedProperties(); });

				for (var i = 0; i < 32; i++)
				{
					var index   = i;
					var content = new GUIContent("Group " + index);
					var on      = P3dHelper.IndexInMask(index, sPro.intValue);

					menu.AddItem(content, on, () => { sPro.intValue ^= 1 << index; sObj.ApplyModifiedProperties(); });
				}

				menu.DropDown(right);
			}
		}
	}
}
#endif

namespace PaintIn3D
{
	[System.Serializable]
	public struct P3dGroupMask
	{
		[SerializeField]
		private int mask;

		public P3dGroupMask(int newMask)
		{
			mask = newMask;
		}

		public static implicit operator int(P3dGroupMask groupMask)
		{
			return groupMask.mask;
		}

		public static implicit operator P3dGroupMask(int mask)
		{
			return new P3dGroupMask(mask);
		}
	}
}