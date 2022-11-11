using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public partial class P3dWindow : P3dEditorWindow
	{
		private void DrawTab0()
		{
			var selectedGameObjects = Selection.GetFiltered<GameObject>(SelectionMode.ExcludePrefab);
			var selectedCount       = 0;

			for (var i = 0; i < selectedGameObjects.Length; i++)
			{
				DrawSelection(selectedGameObjects[i].transform, ref selectedCount);
			}

			if (selectedCount == 0)
			{
				EditorGUILayout.HelpBox("Select any GameObjects in your Hierarchy or Scene that have a MeshFilter+MeshRenderer or SkinnedMeshRenderer.", MessageType.Info);
			}

			if (paintables.Count > 0)
			{
				EditorGUILayout.Separator();

				for (var i = 0; i < paintables.Count; i++)
				{
					var paintable = paintables[i];

					EditorGUILayout.BeginHorizontal();
						P3dHelper.BeginColor(Color.red);
							if (GUILayout.Button("Unlock", GUILayout.Width(50.0f)) == true)
							{
								paintable.Unlock();

								paintables.Remove(paintable);
							}
						P3dHelper.EndColor();
						EditorGUI.BeginDisabledGroup(true);
							EditorGUILayout.ObjectField("", paintable.Root, typeof(GameObject), true);
						EditorGUI.EndDisabledGroup();
						if (GUILayout.Button("Edit", GUILayout.Width(40.0f)) == true)
						{
							tab            = 1;
							paintableIndex = paintables.IndexOf(paintable);
						}
					EditorGUILayout.EndHorizontal();
				}

				EditorGUILayout.Separator();

				P3dHelper.BeginColor(Color.red);
					if (GUILayout.Button("Unlock All") == true)
					{
						for (var i = 0; i < paintables.Count; i++)
						{
							paintables[i].Unlock();
						}

						paintables.Clear();
					}
				P3dHelper.EndColor();
			}
		}

		private void DrawSelection(Transform t, ref int selectedCount)
		{
			var renderer = t.GetComponent<Renderer>();

			if (renderer != null)
			{
				var paintable = paintables.Find(p => p.Root == t.gameObject);

				if (paintable == null)
				{
					EditorGUILayout.BeginHorizontal();
						P3dHelper.BeginColor(Color.green);
							if (GUILayout.Button("Lock", GUILayout.Width(40.0f)) == true)
							{
								paintable = new P3dWindowPaintable(t.gameObject);

								paintables.Add(paintable);
							}
						P3dHelper.EndColor();
						EditorGUI.BeginDisabledGroup(true);
							EditorGUILayout.ObjectField("", t.gameObject, typeof(GameObject), true);
						EditorGUI.EndDisabledGroup();
						P3dHelper.BeginColor(Color.green);
							if (GUILayout.Button("Lock & Edit", GUILayout.Width(80.0f)) == true)
							{
								paintable = new P3dWindowPaintable(t.gameObject);

								paintables.Add(paintable);

								tab            = 1;
								paintableIndex = paintables.IndexOf(paintable);
							}
						P3dHelper.EndColor();
					EditorGUILayout.EndHorizontal();
					selectedCount++;
				}
			}

			for (var i = 0; i < t.childCount; i++)
			{
				DrawSelection(t.GetChild(i), ref selectedCount);
			}
		}
	}
}