using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public partial class P3dWindow : P3dEditorWindow
	{
		private void DrawTab3()
		{
			var data = P3dWindowData.Instance;

			data.MaxUndoSteps        = EditorGUILayout.IntField("Max Undo Steps", data.MaxUndoSteps);
			data.ConfirmDeletePreset = EditorGUILayout.Toggle("Confirm Delete Preset", data.ConfirmDeletePreset);

			if (GUILayout.Button("Save Settings Now") == true)
			{
				P3dWindowData.Save();
			}
		}
	}
}