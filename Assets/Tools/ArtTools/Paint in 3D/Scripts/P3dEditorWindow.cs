#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public class P3dEditorWindow : EditorWindow
	{
		[SerializeField]
		private Vector2 mousePosition;

		[SerializeField]
		protected Vector2 scrollPosition;
        protected virtual void OnEnable()
		{
			SceneView.onSceneGUIDelegate += OnSceneGUI;
		}

		protected virtual void OnDisable()
		{
			SceneView.onSceneGUIDelegate -= OnSceneGUI;
		}

		protected virtual void OnGUI()
		{
			P3dHelper.ClearColors();
			scrollPosition = GUILayout.BeginScrollView(scrollPosition);
			{
				EditorGUI.BeginChangeCheck();
				{
					OnInspector();
				}
				if (EditorGUI.EndChangeCheck() == true)
				{
					SceneView.RepaintAll();
				}
			}
			GUILayout.EndScrollView();
		}

		protected virtual void OnSceneGUI(SceneView sceneView)
		{
			var camera = sceneView.camera;

			mousePosition = Event.current.mousePosition;

			if (camera != null)
			{
				Handles.BeginGUI();
				{
					OnScene(sceneView, camera, mousePosition);
				}
				Handles.EndGUI();

				//sceneView.Repaint();
			}
		}

		protected virtual void OnSelectionChange()
		{
			Repaint();
		}

		protected virtual void OnInspector()
		{
		}

		protected virtual void OnScene(SceneView sceneView, Camera camera, Vector2 mousePosition)
		{
        }
	}
}
#endif