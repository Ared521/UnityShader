using UnityEngine;
using UnityEditor;

namespace PaintIn3D
{
	public partial class P3dWindow : P3dEditorWindow
	{
		private void DrawTab2()
		{
			var brush         = P3dWindowData.Instance.Brush;
			var presetBrushes = P3dWindowData.Instance.PresetBrushes;

            if (CanPaint() == true)
            {
                var oldCol = GUI.color;
                GUI.color = Color.green;
                GUILayout.Label("快捷键：在Scene窗口下才有用");
                GUILayout.Label("笔刷硬度：大键盘- =键");
                GUILayout.Label("笔刷大小：大键盘[ ]键");
                GUILayout.Label("\"~\"键：来回切换Additive和SubAdditive模式");
                GUILayout.Label("红:1, 绿:2,蓝:3,白色:4");
                GUILayout.Label("撤销、重做：Alt + Z 、Alt + X");
                GUI.color = oldCol;
            }

            if (CanPaint() == true)
			{
				EditorGUILayout.BeginHorizontal();
					EditorGUI.BeginDisabledGroup(CanUndo() == false);
						if (GUILayout.Button("Undo") == true)
						{
							Undo();
						}
					EditorGUI.EndDisabledGroup();
					EditorGUI.BeginDisabledGroup(CanWrite() == false);
						P3dHelper.BeginColor(NeedsWrite() == true ? Color.green : GUI.color);
							if (GUILayout.Button(new GUIContent("Write", "If you're editing imported textures (e.g. .png), then they must be written to apply changes.")) == true)
							{
								Write();
							}
						P3dHelper.EndColor();
					EditorGUI.EndDisabledGroup();
					EditorGUI.BeginDisabledGroup(CanRedo() == false);
						if (GUILayout.Button("Redo") == true)
						{
							Redo();
						}
					EditorGUI.EndDisabledGroup();
				EditorGUILayout.EndHorizontal();
			}
			else
			{
				EditorGUILayout.HelpBox("Before you can paint, you need to lock at least one texture.", MessageType.Info);
			}

			EditorGUILayout.Separator();

			brush.OnGUI();

			if (GUILayout.Button("Save As Preset") == true)
			{
				var exists = presetBrushes.Exists(p => p.Name == brush.Name);

				if (exists == false || EditorUtility.DisplayDialog("Overwrite brush?", "You already have a preset brush with this name. Overwrite it?", "Yes", "Cancel") == true)
				{
					var newPreset = presetBrushes.Find(p => p.Name == brush.Name);

					if (newPreset == null)
					{
						newPreset = new P3dWindowBrush();

						presetBrushes.Add(newPreset);
					}

					brush.CopyTo(newPreset);
				}
			}

			EditorGUILayout.Separator();

			brush.Tip0.OnGUI();

			EditorGUILayout.Separator();

			//brush.Tip1.OnGUI();

			//EditorGUILayout.Separator();

			//brush.Tip2.OnGUI();

			//EditorGUILayout.Separator();

			//brush.Tip3.OnGUI();

			if (presetBrushes.Count > 0)
			{
				EditorGUILayout.Separator();

				EditorGUILayout.LabelField("Preset Brushes", EditorStyles.boldLabel);

				for (var i = 0; i < presetBrushes.Count; i++)
				{
					var presetBrush = presetBrushes[i];

					EditorGUILayout.BeginHorizontal();
					EditorGUI.BeginDisabledGroup(i <= 0);
						if (GUILayout.Button("▲", GUILayout.Width(20)) == true)
						{
							presetBrushes[i] = presetBrushes[i - 1];
							presetBrushes[i - 1] = presetBrush;
						}
					EditorGUI.EndDisabledGroup();
					EditorGUI.BeginDisabledGroup(i >= presetBrushes.Count - 1);
						if (GUILayout.Button("▼", GUILayout.Width(20)) == true)
						{
							presetBrushes[i] = presetBrushes[i + 1];
							presetBrushes[i + 1] = presetBrush;
						}
					EditorGUI.EndDisabledGroup();
					if (GUILayout.Button(presetBrush.Name) == true)
					{
						presetBrush.CopyTo(brush);
					}
					P3dHelper.BeginColor(Color.red);
						if (GUILayout.Button("X", GUILayout.Width(20)) == true)
						{
							if (P3dWindowData.Instance.ConfirmDeletePreset == false || EditorUtility.DisplayDialog("Delete preset brush?", "This cannot be undone.\n(You can disable this warning in the Extras tab)", "Delete", "Cancel") == true)
							{
								presetBrushes.RemoveAt(i);
							}
						}
					P3dHelper.EndColor();
					EditorGUILayout.EndHorizontal();
				}
			}
		}

		private bool CanPaint()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				if (paintables[i].CanPaint() == true)
				{
					return true;
				}
			}

			return false;
		}

		private bool CanUndo()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				if (paintables[i].CanUndo() == true)
				{
					return true;
				}
			}

			return false;
		}

		private bool CanWrite()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				if (paintables[i].CanWrite() == true)
				{
					return true;
				}
			}

			return false;
		}

		private bool NeedsWrite()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				if (paintables[i].NeedsWrite() == true)
				{
					return true;
				}
			}

			return false;
		}

		private bool CanRedo()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				if (paintables[i].CanRedo() == true)
				{
					return true;
				}
			}

			return false;
		}

		private void Undo()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				paintables[i].Undo();
			}
		}

		private void Write()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				paintables[i].Write();
			}
		}

		private void Redo()
		{
			for (var i = paintables.Count - 1; i >= 0; i--)
			{
				paintables[i].Redo();
			}
		}

        protected override void OnSceneGUI(SceneView sceneView)
        {
            base.OnSceneGUI(sceneView);
            var brush = P3dWindowData.Instance.Brush;
            var ray = GetRay(sceneView.camera, lastMousePosition);
            var hit = default(RaycastHit);

            if (Raycast(ray, ref hit) == true)
            {
                Vector3 normal = Vector3.forward;
                var brushSize = brush.Tip0.Radius;
                Handles.color = new Color(brush.Tip0.Color.r, brush.Tip0.Color.g, brush.Tip0.Color.b, 1.0f);
                float hardbrush = 1.0f - Mathf.Pow(0.5f, brush.Tip0.Hardness);
                Handles.DrawWireDisc(hit.point, hit.normal, brushSize * hardbrush);
                Handles.DrawWireDisc(hit.point, hit.normal, brushSize);
                Handles.DrawLine(hit.point, hit.point + hit.normal * 0.2f);
                //Handles.color = new Color(1.0f, 1.0f, 1.0f, 0.1f);
                //Handles.DrawSolidDisc(hit.point, hit.normal, brushSize);
            }

            //快捷鍵
            var curCam = SceneView.currentDrawingSceneView.camera;
            int controlID = GUIUtility.GetControlID(FocusType.Passive);

            if (Event.current.GetTypeForControl(controlID) == EventType.KeyDown)
            {
                if (Event.current.keyCode == KeyCode.LeftBracket)
                {
                    brush.Tip0.Radius -= 0.02f;
                    brush.Tip0.Radius = Mathf.Max(brush.Tip0.Radius, 0.0f);
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.RightBracket)
                {
                    brush.Tip0.Radius += 0.02f;
                    brush.Tip0.Radius = Mathf.Max(brush.Tip0.Radius, 0.0f);
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.Minus)
                {
                    brush.Tip0.Hardness -= 0.05f;
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.Equals)
                {
                    brush.Tip0.Hardness += 0.05f;
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.alt && Event.current.keyCode == KeyCode.Z)
                {
                    Undo();
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.alt && Event.current.keyCode == KeyCode.X)
                {
                    Redo();
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.BackQuote)
                {
                    brush.Tip0.BlendMode = (brush.Tip0.BlendMode == P3dBlendMode.Additive) ? P3dBlendMode.Subtractive : P3dBlendMode.Additive;
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.Alpha1)
                {
                    if (brush.Tip0.BlendMode == P3dBlendMode.Replace)
                    {
                        brush.Tip0.Color = new Color(1.0f, 0.0f, 0.0f, 0.0f);
                    }
                    else
                    {
                        brush.Tip0.Color = Color.red;
                    }
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.Alpha2)
                {
                    if (brush.Tip0.BlendMode == P3dBlendMode.Replace)
                    {
                        brush.Tip0.Color = new Color(0.0f, 1.0f, 0.0f, 0.0f);
                    }
                    else
                    {
                        brush.Tip0.Color = Color.green;
                    }
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.Alpha3)
                {
                    if (brush.Tip0.BlendMode == P3dBlendMode.Replace)
                    {
                        brush.Tip0.Color = new Color(0.0f, 0.0f, 1.0f, 0.0f);
                    }
                    else
                    {
                        brush.Tip0.Color = Color.blue;
                    }
                    Event.current.Use();
                    this.Repaint();
                }
                if (Event.current.keyCode == KeyCode.Alpha4)
                {
                    if (brush.Tip0.BlendMode == P3dBlendMode.Replace)
                    {
                        brush.Tip0.Color = new Color(0.0f, 0.0f, 0.0f, 1.0f);
                    }
                    else
                    {
                        brush.Tip0.Color = Color.white;
                    }
                    Event.current.Use();
                    this.Repaint();
                }
            }
        }
    }
}