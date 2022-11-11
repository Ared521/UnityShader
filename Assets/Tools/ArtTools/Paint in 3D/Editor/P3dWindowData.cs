using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public class P3dWindowData
	{
		public static P3dWindowData Instance = new P3dWindowData();

		public static bool Loaded;

		public P3dWindowBrush Brush = new P3dWindowBrush();

		public List<P3dWindowBrush> PresetBrushes = new List<P3dWindowBrush>();

		public int MaxUndoSteps = 10;

		public bool ConfirmDeletePreset = true;

		public static void Load()
		{
			if (Loaded == false)
			{
				Loaded = true;

				if (EditorPrefs.HasKey("P3dWindow") == true)
				{
					EditorJsonUtility.FromJsonOverwrite(EditorPrefs.GetString("P3dWindow"), Instance);
				}
			}
		}

		public static void Save()
		{
			EditorPrefs.SetString("P3dWindow", EditorJsonUtility.ToJson(Instance));
		}
	}
}