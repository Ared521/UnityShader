using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	[System.Serializable]
	public class P3dWindowBrush
	{
		public string            Name     = "Default Brush";
		public float             DragStep = 3.0f;
		public P3dWindowBrushTip Tip0     = new P3dWindowBrushTip(P3dWindowBrushTechnique.Decal);
		public P3dWindowBrushTip Tip1     = new P3dWindowBrushTip(P3dWindowBrushTechnique.None);
		public P3dWindowBrushTip Tip2     = new P3dWindowBrushTip(P3dWindowBrushTechnique.None);
		public P3dWindowBrushTip Tip3     = new P3dWindowBrushTip(P3dWindowBrushTechnique.None);

		public void CopyTo(P3dWindowBrush other)
		{
			other.Name     = Name;
			other.DragStep = DragStep;

			Tip0.CopyTo(other.Tip0);
			Tip1.CopyTo(other.Tip1);
			Tip2.CopyTo(other.Tip2);
			Tip3.CopyTo(other.Tip3);
		}

		public void OnGUI()
		{
			Name     = EditorGUILayout.TextField("Name", Name);
			DragStep = EditorGUILayout.FloatField("Drag Step", DragStep);
		}
	}

	public enum P3dWindowBrushTechnique
	{
		None,
		Replace,
		Fill,
		Sphere,
		Decal,
		SphereTriplanar,
		SphereBlur
	}

	[System.Serializable]
	public class P3dWindowBrushTip
	{
		public P3dWindowBrushTechnique Technique;
		public P3dGroup                Group;
		public P3dBlendMode            BlendMode;
		public Texture                 Texture;
		public Texture                 Shape;
		public float                   Strength   = 1.0f;
		public float                   Tiling     = 1.0f;
		public Color                   Color      = Color.white;
		public float                   Opacity    = 1.0f;
		public float                   KernelSize = 0.001f;
		public float                   Radius     = 0.25f;
		public float                   Depth      = 1.0f;
		public float                   Hardness   = 1.0f;
		public float                   OneSided   = 1.0f;

		public P3dWindowBrushTip(P3dWindowBrushTechnique newTechnique)
		{
			Technique = newTechnique;
		}

		public void CopyTo(P3dWindowBrushTip other)
		{
			other.Technique  = Technique;
			other.Group      = Group;
			other.BlendMode  = BlendMode;
			other.Texture    = Texture;
			other.Shape      = Shape;
			other.Strength   = Strength;
			other.Tiling     = Tiling;
			other.Color      = Color;
			other.Opacity    = Opacity;
			other.KernelSize = KernelSize;
			other.Radius     = Radius;
			other.Depth      = Depth;
			other.Hardness   = Hardness;
			other.OneSided   = OneSided;
		}

		private Texture Deserialize(string path)
		{
			if (string.IsNullOrEmpty(path) == false)
			{
				return AssetDatabase.LoadAssetAtPath(path, typeof(Texture)) as Texture;
			}

			return null;
		}

		private string Serialize(Texture texture)
		{
			if (texture != null)
			{
				return AssetDatabase.GetAssetPath(texture);
			}

			return null;
		}

		public void OnGUI()
		{
			Technique = (P3dWindowBrushTechnique)EditorGUILayout.EnumPopup("Technique", Technique);

			EditorGUI.indentLevel++;
				switch (Technique)
				{
					case P3dWindowBrushTechnique.Replace:
					{
						//P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), this, new GUIContent("Group"));
						Texture = EditorGUI.ObjectField(P3dHelper.Reserve(), "Texture", Texture, typeof(Texture), false) as Texture;
						Color   = EditorGUILayout.ColorField("Color", Color);
						Opacity = EditorGUILayout.Slider("Opacity", Opacity, 0.0f, 1.0f);
					}
					break;

					case P3dWindowBrushTechnique.Fill:
					{
						//P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), this, new GUIContent("Group"));
						BlendMode = (P3dBlendMode)EditorGUILayout.EnumPopup("Blend Mode", BlendMode);
						Texture   = EditorGUI.ObjectField(P3dHelper.Reserve(), "Texture", Texture, typeof(Texture), false) as Texture;
						Color     = EditorGUILayout.ColorField("Color", Color);
						Opacity   = EditorGUILayout.Slider("Opacity", Opacity, 0.0f, 1.0f);
					}
					break;

					case P3dWindowBrushTechnique.Sphere:
					{
						//P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), this, new GUIContent("Group"));
						BlendMode = (P3dBlendMode)EditorGUILayout.EnumPopup("Blend Mode", BlendMode);
						Color     = EditorGUILayout.ColorField("Color", Color);
						Opacity   = EditorGUILayout.Slider("Opacity", Opacity, 0.0f, 1.0f);
						Radius    = EditorGUILayout.FloatField("Radius", Radius);
                        Hardness = EditorGUILayout.Slider("Hardness", Hardness, 0.01f, 5.0f);
                    }
					break;

					case P3dWindowBrushTechnique.Decal:
					{
						//P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), this, new GUIContent("Group"));
						BlendMode = (P3dBlendMode)EditorGUILayout.EnumPopup("Blend Mode", BlendMode);
						P3dHelper.BeginColor(Texture == null);
							Texture = EditorGUI.ObjectField(P3dHelper.Reserve(), "Texture", Texture, typeof(Texture), false) as Texture;
						P3dHelper.EndColor();
						if (BlendMode == P3dBlendMode.Replace)
						{
							P3dHelper.BeginColor(Shape == null);
								Shape = EditorGUI.ObjectField(P3dHelper.Reserve(), "Shape", Shape, typeof(Texture), false) as Texture;
							P3dHelper.EndColor();
						}
						Color    = EditorGUILayout.ColorField("Color", Color);
						Opacity  = EditorGUILayout.Slider("Opacity", Opacity, 0.0f, 1.0f);
						Radius   = EditorGUILayout.FloatField("Radius", Radius);
						Depth    = EditorGUILayout.FloatField("Depth", Depth);
                        Hardness = EditorGUILayout.Slider("Hardness", Hardness, 0.01f, 5.0f);
                        OneSided = EditorGUILayout.FloatField("OneSided", OneSided);
					}
					break;

					case P3dWindowBrushTechnique.SphereTriplanar:
					{
						//P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), this, new GUIContent("Group"));
						BlendMode = (P3dBlendMode)EditorGUILayout.EnumPopup("Blend Mode", BlendMode);
						P3dHelper.BeginColor(Texture == null);
							Texture = EditorGUI.ObjectField(P3dHelper.Reserve(), "Texture", Texture, typeof(Texture), false) as Texture;
						P3dHelper.EndColor();
						Strength = EditorGUILayout.FloatField("Strength", Strength);
						Tiling   = EditorGUILayout.FloatField("Tiling", Tiling);
						Color    = EditorGUILayout.ColorField("Color", Color);
						Opacity  = EditorGUILayout.Slider("Opacity", Opacity, 0.0f, 1.0f);
						Radius   = EditorGUILayout.FloatField("Radius", Radius);
						Hardness = EditorGUILayout.Slider("Hardness", Hardness, 0.01f, 5.0f);
					}
					break;

					case P3dWindowBrushTechnique.SphereBlur:
					{
						//P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), this, new GUIContent("Group"));
						Opacity    = EditorGUILayout.Slider("Opacity", Opacity, 0.0f, 1.0f);
						KernelSize = EditorGUILayout.Slider("Kernel Size", KernelSize, 0.0001f, 0.1f);
						Radius     = EditorGUILayout.FloatField("Radius", Radius);
						Hardness   = EditorGUILayout.Slider("Hardness", Hardness, 0.01f, 5.0f);
					}
					break;
				}
			EditorGUI.indentLevel--;
		}

		public bool Paint(RaycastHit hit, List<P3dWindowPaintable> paintables)
		{
			switch (Technique)
			{
				case P3dWindowBrushTechnique.Replace:
				{
					var command = new P3dPainter.Replace();

					P3dPainter.Replace.SetMaterial(Texture, Color, Opacity);
					P3dPainter.Replace.CopyTo(command);

					for (var i = paintables.Count - 1; i >= 0; i--)
					{
						paintables[i].Paint(Group, command);
					}
				}
				return true;

				case P3dWindowBrushTechnique.Fill:
				{
					var command = new P3dPainter.Fill();

					P3dPainter.Fill.SetMaterial(BlendMode, Texture, Color, Opacity);
					P3dPainter.Fill.CopyTo(command);

					for (var i = paintables.Count - 1; i >= 0; i--)
					{
						paintables[i].Paint(Group, command);
					}
				}
				return true;

				case P3dWindowBrushTechnique.Sphere:
				{
					var command = new P3dPainter.Sphere();

					P3dPainter.Sphere.SetMatrix(hit.point, Radius);
					P3dPainter.Sphere.SetMaterial(BlendMode, Hardness, Color, Opacity);
					P3dPainter.Sphere.CopyTo(command);

					for (var i = paintables.Count - 1; i >= 0; i--)
					{
						paintables[i].Paint(Group, command);
					}
				}
				return true;

				case P3dWindowBrushTechnique.Decal:
				{
					var command = new P3dPainter.Decal();

					P3dPainter.Decal.SetMatrix(hit.point, hit.normal, 0.0f, Radius, Texture, Depth, false);
					P3dPainter.Decal.SetMaterial(BlendMode, Texture, Hardness, OneSided, Color, Opacity, Shape);
					P3dPainter.Decal.CopyTo(command);

					for (var i = paintables.Count - 1; i >= 0; i--)
					{
						paintables[i].Paint(Group, command);
					}
				}
				return true;

				case P3dWindowBrushTechnique.SphereTriplanar:
				{
					var command = new P3dPainter.SphereTriplanar();

					P3dPainter.SphereTriplanar.SetMatrix(hit.point, Radius);
					P3dPainter.SphereTriplanar.SetMaterial(BlendMode, Hardness, Texture, Strength, Tiling, Color, Opacity);
					P3dPainter.SphereTriplanar.CopyTo(command);

					for (var i = paintables.Count - 1; i >= 0; i--)
					{
						paintables[i].Paint(Group, command);
					}
				}
				return true;

				case P3dWindowBrushTechnique.SphereBlur:
				{
					var command = new P3dPainter.SphereBlur();

					P3dPainter.SphereBlur.SetMatrix(hit.point, Radius);
					P3dPainter.SphereBlur.SetMaterial(Hardness, Opacity, KernelSize);
					P3dPainter.SphereBlur.CopyTo(command);

					for (var i = paintables.Count - 1; i >= 0; i--)
					{
						paintables[i].Paint(Group, command);
					}
				}
				return true;
			}

			return false;
		}
	}
}