#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.Collections.Generic;

namespace PaintIn3D
{
	public abstract class P3dEditor<T> : Editor
		where T : Object
	{
		protected T Target;

		protected T[] Targets;

		private static GUIContent customContent = new GUIContent();

		public override void OnInspectorGUI()
		{
			EditorGUI.BeginChangeCheck();

			Target  = (T)target;
			Targets = targets.Select(t => (T)t).ToArray();

			P3dHelper.ClearColors();

			Separator();

			OnInspector();

			Separator();

			serializedObject.ApplyModifiedProperties();

			if (EditorGUI.EndChangeCheck() == true)
			{
				GUI.changed = true; Repaint();

				foreach (var t in Targets)
				{
					EditorUtility.SetDirty(t);
				}
			}
		}

		public virtual void OnSceneGUI()
		{
			Target = (T)target;

			OnScene();

			if (GUI.changed == true)
			{
				EditorUtility.SetDirty(target);
			}
		}

		protected static void ForceExecutionOrder(int order)
		{
			var scripts = MonoImporter.GetAllRuntimeMonoScripts();

			for (var i = scripts.Length - 1; i >= 0; i--)
			{
				var script = scripts[i];

				if (script != null && script.name == typeof(T).Name)
				{
					if (MonoImporter.GetExecutionOrder(script) != order)
					{
						MonoImporter.SetExecutionOrder(script, order);
					}

					return;
				}
			}
		}

		protected void Each(System.Action<T> update)
		{
			foreach (var t in Targets)
			{
				update(t);
			}
		}

		protected bool Any(System.Func<T, bool> check)
		{
			foreach (var t in Targets)
			{
				if (check(t) == true)
				{
					return true;
				}
			}

			return false;
		}

		protected bool All(System.Func<T, bool> check)
		{
			foreach (var t in Targets)
			{
				if (check(t) == false)
				{
					return false;
				}
			}

			return true;
		}

		protected virtual void Separator()
		{
			EditorGUILayout.Separator();
		}

		protected void BeginIndent()
		{
			EditorGUI.indentLevel += 1;
		}

		protected void EndIndent()
		{
			EditorGUI.indentLevel -= 1;
		}

		protected bool Button(string text)
		{
			var rect = P3dHelper.Reserve();

			return GUI.Button(rect, text);
		}

		protected bool HelpButton(string helpText, UnityEditor.MessageType type, string buttonText, float buttonWidth)
		{
			var clicked = false;

			EditorGUILayout.BeginHorizontal();
			{
				EditorGUILayout.HelpBox(helpText, type);

				var style = new GUIStyle(GUI.skin.button); style.wordWrap = true;

				clicked = GUILayout.Button(buttonText, style, GUILayout.ExpandHeight(true), GUILayout.Width(buttonWidth));
			}
			EditorGUILayout.EndHorizontal();

			return clicked;
		}

		protected void BeginMixed(bool mixed = true)
		{
			EditorGUI.showMixedValue = mixed;
		}

		protected void EndMixed()
		{
			EditorGUI.showMixedValue = false;
		}

		protected void BeginDisabled(bool disabled = true)
		{
			EditorGUI.BeginDisabledGroup(disabled);
		}

		protected void EndDisabled()
		{
			EditorGUI.EndDisabledGroup();
		}

		protected void BeginError(bool error = true)
		{
			P3dHelper.BeginColor(error);
		}

		protected void EndError()
		{
			P3dHelper.EndColor();
		}

		protected bool DrawDefaultRelative(SerializedProperty property, string propertyPath, string overrideTooltip = null, string overrideName = null)
		{
			property = property.FindPropertyRelative(propertyPath);

			return DrawProperty(property, overrideTooltip, overrideName);
		}

		protected bool DrawDefault(string propertyPath, string overrideTooltip = null, string overrideName = null)
		{
			var property = serializedObject.FindProperty(propertyPath);

			return DrawProperty(property, overrideTooltip,overrideName);
		}

		protected bool DrawProperty(SerializedProperty property, string overrideTooltip = null, string overrideName = null)
		{
			EditorGUI.BeginChangeCheck();
			{
				customContent.text    = property.displayName;
				customContent.tooltip = property.tooltip;

				if (string.IsNullOrEmpty(overrideName) == false)
				{
					customContent.text = overrideName;
				}

				if (string.IsNullOrEmpty(overrideTooltip) == false)
				{
					customContent.tooltip = overrideTooltip;
				}

				EditorGUILayout.PropertyField(property, customContent, true);
			}
			if (EditorGUI.EndChangeCheck() == true)
			{
				serializedObject.ApplyModifiedProperties();

				for (var i = Targets.Length - 1; i >= 0; i--)
				{
					P3dHelper.SetDirty(Targets[i]);
				}

				return true;
			}

			return false;
		}

		protected void DrawDefault(string propertyPath, ref bool modified, string overrideTooltip = null, string overrideName = null)
		{
			if (DrawDefault(propertyPath, overrideTooltip, overrideName) == true)
			{
				modified = true;
			}
		}

		protected void DrawDefault(string propertyPath, ref bool modified1, ref bool modified2, string overrideTooltip = null, string overrideName = null)
		{
			if (DrawDefault(propertyPath, overrideTooltip, overrideName) == true)
			{
				modified1 = true;
				modified2 = true;
			}
		}

		protected virtual void OnInspector()
		{
		}

		protected virtual void OnScene()
		{
		}
	}
}
#endif