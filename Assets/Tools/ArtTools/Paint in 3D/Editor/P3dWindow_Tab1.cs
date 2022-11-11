using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public partial class P3dWindow : P3dEditorWindow
	{
		private List<P3dWindowPaintable> paintables = new List<P3dWindowPaintable>();

		private int paintableIndex;

		private TextureFormat createFormat  = TextureFormat.ARGB32;
		private bool          createMipMaps = true;
		private bool          createLinear  = true;
		private Color         createColor   = Color.white;
		private int           createWidth   = 512;
		private int           createHeight  = 512;
		private bool          createFailed;
		private bool          changeFormat;
		private TextureFormat changeFormatNew;
		private bool          changeFormatFailed;
		private bool          changeSize;
		private bool          changeSizeFailed;
		private int           changeWidth  = 512;
		private int           changeHeight = 512;

		private void DrawTab1()
		{
			ValidatePaintables();

			if (paintables.Count > 0)
			{
				paintableIndex = P3dHelper.Mod(paintableIndex, paintables.Count);

				var paintable = paintables[paintableIndex];

				EditorGUILayout.BeginHorizontal();
					EditorGUI.BeginDisabledGroup(paintables.Count <= 1);
						if (GUILayout.Button("<", GUILayout.Width(20.0f)))
						{
							paintableIndex -= 1; Repaint();
						}
					EditorGUI.EndDisabledGroup();
					if (GUILayout.Button((paintableIndex + 1) + "/" + paintables.Count + " " + paintable.Root.name))
					{
						Selection.activeGameObject = paintable.Root; EditorGUIUtility.PingObject(paintable.Root);
					}
					EditorGUI.BeginDisabledGroup(paintables.Count <= 1);
						if (GUILayout.Button(">", GUILayout.Width(20.0f)))
						{
							paintableIndex += 1; Repaint();
						}
					EditorGUI.EndDisabledGroup();
				EditorGUILayout.EndHorizontal();

				if (CanPaint() == false)
				{
					EditorGUILayout.HelpBox("Pick a texture you want to paint by expanding it and then locking it.", MessageType.Info);
				}

				var renderer  = paintable.Root.GetComponent<Renderer>();
				var materials = renderer.sharedMaterials;

				for (var i = 0; i < materials.Length; i++)
				{
					EditorGUILayout.Separator();

					materials[i] = DrawMaterial(paintable, materials[i], i);
				}

				renderer.sharedMaterials = materials;
			}
			else
			{
				EditorGUILayout.HelpBox("Before you can pick a texture, you need to lock at least one object.", MessageType.Info);
			}
		}

		private Material DrawMaterial(P3dWindowPaintable paintable, Material material, int materialIndex)
		{
			EditorGUILayout.BeginHorizontal();
				EditorGUILayout.LabelField("Material " + materialIndex, EditorStyles.boldLabel, GUILayout.Width(120.0f));
				material = (Material)EditorGUILayout.ObjectField("", material, typeof(Material), false);
			EditorGUILayout.EndHorizontal();

			if (material != null)
			{
				if (material.hideFlags != HideFlags.None)
				{
					EditorGUILayout.HelpBox("This may be a shared material, so you should clone it before modification.", MessageType.Warning);
				}

				if (GUILayout.Button("Clone") == true)
				{
					material = Instantiate(material);
				}

				if (P3dHelper.IsAsset(material) == false && GUILayout.Button("Save As Asset") == true)
				{
					var path = P3dHelper.SaveDialog("Save Material As Asset", "Assets", material.name, "mat");

					if (string.IsNullOrEmpty(path) == false)
					{
						var textures = P3dHelper.CopyTextures(material);

						AssetDatabase.CreateAsset(material, path);

						P3dHelper.PasteTextures(material, textures);
					}
				}

				var texEnvs = P3dHelper.GetTexEnvs(material);

				if (texEnvs.Count > 0)
				{
					for (var j = 0; j < texEnvs.Count; j++)
					{
						var texEnv           = texEnvs[j];
						var rect             = P3dHelper.Reserve();
						var paintableTexture = paintable.PaintableTextures.Find(t => t.MaterialIndex == materialIndex && t.SlotName == texEnv.Name);

						EditorGUI.BeginDisabledGroup(paintableTexture != null && paintableTexture.Locked == true);
							var texture = EditorGUI.ObjectField(rect, default(string), material.GetTexture(texEnv.Name), typeof(Texture), true) as Texture;
						EditorGUI.EndDisabledGroup();

						// Make sure this is done after the texture field so it can be edited
						var expand = EditorGUI.Foldout(rect, paintableTexture != null, new GUIContent(texEnv.Name, texEnv.Desc), false);

						if (expand == true)
						{
							if (paintableTexture == null)
							{
								paintableTexture = new P3dWindowPaintableTexture(paintable, materialIndex, texEnv.Name); paintable.PaintableTextures.Add(paintableTexture);
							}

							paintableTexture.Revert();

							EditorGUILayout.BeginVertical("box");
								texture = DrawObject(paintableTexture, material, texture);
							EditorGUILayout.EndVertical();
						}
						else
						{
							if (paintableTexture != null)
							{
								paintableTexture.Unlock();

								paintable.PaintableTextures.Remove(paintableTexture);
							}
						}

						material.SetTexture(texEnv.Name, texture);
					}
				}
				else
				{
					EditorGUILayout.HelpBox("This material's shader has no texture slots.", MessageType.Info);
				}
			}
			else
			{
				EditorGUILayout.HelpBox("There is no material in this material slot.", MessageType.Info);
			}

			return material;
		}

		private Texture DrawObject(P3dWindowPaintableTexture paintableTexture, Material material, Texture texture)
		{
			if (texture != null)
			{
				var texture2D = texture as Texture2D;

				if (texture2D != null)
				{
					EditorGUI.BeginDisabledGroup(paintableTexture.Locked == true);
						if (material.hideFlags != HideFlags.None)
						{
							EditorGUILayout.HelpBox("This may be a shared texture, so you should clone it before modification.", MessageType.Warning);
						}

						if (GUILayout.Button("Clone") == true)
						{
							texture = texture2D = Instantiate(texture2D);
						}

						var textureImporter = P3dHelper.GetAssetImporter<TextureImporter>(texture);

						if (textureImporter != null)
						{
							if (textureImporter.isReadable == false)
							{
								EditorGUILayout.HelpBox("This texture's import settings does not have Read/Write Enabled.", MessageType.Error);

								P3dHelper.BeginColor(Color.green);
									if (GUILayout.Button("Enable Read/Write") == true)
									{
										textureImporter.isReadable = true;

										textureImporter.SaveAndReimport();
									}
								P3dHelper.EndColor();
							}
						}
						else
						{
							changeFormat = EditorGUILayout.Foldout(changeFormat, "Change Format");

							if (changeFormat == true)
							{
								EditorGUI.BeginDisabledGroup(true);
									EditorGUILayout.EnumPopup("Current Format", texture2D.format, EditorStyles.popup);
								EditorGUI.EndDisabledGroup();

								changeFormatNew = (TextureFormat)EditorGUILayout.EnumPopup("New Format", changeFormatNew, EditorStyles.popup);

								P3dHelper.BeginColor(Color.green);
									if (GUI.Button(P3dHelper.Reserve(), "Change Format") == true)
									{
										var newTexture2D = new Texture2D(texture2D.width, texture2D.height, changeFormatNew, texture2D.mipmapCount > 0);

										changeFormatFailed = true;

										if (CanReadWrite(newTexture2D) == true)
										{
											var readableTexture = P3dHelper.GetReadableTexture(texture2D);
											var pixels          = readableTexture.GetPixels32();

											P3dHelper.Destroy(readableTexture);

											newTexture2D.name = texture2D.name;
											newTexture2D.SetPixels32(pixels);
											newTexture2D.Apply();

											texture            = texture2D = newTexture2D;
											changeFormat       = false;
											changeFormatFailed = false;
										}
									}
								P3dHelper.EndColor();

								if (changeFormatFailed == true)
								{
									EditorGUILayout.HelpBox("Failed to change format. This means the format you tried to use is not readable.", MessageType.Error);
								}
							}

							changeSize = EditorGUILayout.Foldout(changeSize, "Change Size");

							if (changeSize == true)
							{
								EditorGUI.BeginDisabledGroup(true);
									EditorGUILayout.IntField("Current Width", texture2D.width);
									EditorGUILayout.IntField("Current Height", texture2D.height);
								EditorGUI.EndDisabledGroup();
								changeWidth  = EditorGUILayout.IntField("Width", changeWidth);
								changeHeight = EditorGUILayout.IntField("Height", changeHeight);

								P3dHelper.BeginColor(Color.green);
									if (GUILayout.Button("Change Size") == true)
									{
										var newTexture2D = new Texture2D(changeWidth, changeHeight, texture2D.format, texture2D.mipmapCount > 0);

										changeSizeFailed = true;

										if (CanReadWrite(newTexture2D) == true)
										{
											var readableTexture = P3dHelper.GetReadableTexture(texture2D, TextureFormat.ARGB32, false, changeWidth, changeHeight);
											var pixels          = readableTexture.GetPixels32();

											P3dHelper.Destroy(readableTexture);

											newTexture2D.name = texture2D.name;
											newTexture2D.SetPixels32(pixels);
											newTexture2D.Apply();

											texture          = texture2D = newTexture2D;
											changeSize       = false;
											changeSizeFailed = false;
										}
									}
								P3dHelper.EndColor();

								if (changeSizeFailed == true)
								{
									EditorGUILayout.HelpBox("Failed to change size. Either the texture format is non-readable, or the texture size you chose is invalid.", MessageType.Error);
								}
							}
						}

						if (P3dHelper.IsAsset(material) == true && P3dHelper.IsAsset(texture) == false)
						{
							EditorGUILayout.HelpBox("This texture is stored in the scene, but it's applied to a material that's stored in an asset. You should save the texture as an asset too, otherwise it won't work properly.", MessageType.Warning);
						}

						if (P3dHelper.IsAsset(texture) == false)
						{
							if (GUILayout.Button("Save As Texture2D Asset") == true)
							{
								var path = P3dHelper.SaveDialog("Save Texture As Asset", "Assets", texture.name, "asset");

								if (string.IsNullOrEmpty(path) == false)
								{
									AssetDatabase.CreateAsset(texture, path);
								}
							}

							if (GUILayout.Button("Save As Png Asset") == true)
							{
								var path = P3dHelper.SaveDialog("Export Texture", "Assets", texture.name, "png");

								if (string.IsNullOrEmpty(path) == false)
								{
									P3dHelper.SaveTextureAsset(texture, path, true);

									var newTexture2D = (Texture2D)AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D));

									if (newTexture2D != null)
									{
										//ClearUndo();

										var importer = P3dHelper.GetAssetImporter<TextureImporter>(newTexture2D);

										importer.isReadable         = true;
										importer.textureCompression = TextureImporterCompression.Uncompressed;
										importer.filterMode         = FilterMode.Trilinear;
										importer.anisoLevel         = 8;
										importer.SaveAndReimport();

										texture = texture2D = newTexture2D;

										P3dHelper.SetDirty(this);
									}
								}
							}
						}
					EditorGUI.EndDisabledGroup();

					if (paintableTexture.Locked == true)
					{
						EditorGUILayout.BeginHorizontal();
							P3dHelper.BeginColor(Color.red);
								if (GUILayout.Button("Unlock", GUILayout.Width(50.0f)) == true)
								{
									paintableTexture.Unlock();
								}
							P3dHelper.EndColor();
							P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), paintableTexture);
							paintableTexture.Channel = (P3dChannel)EditorGUILayout.EnumPopup(paintableTexture.Channel);
							if (GUILayout.Button("Paint", GUILayout.Width(45.0f)) == true)
							{
								tab = 2;
							}
						EditorGUILayout.EndHorizontal();
					}
					else
					{
						EditorGUILayout.BeginHorizontal();
							P3dHelper.BeginColor(Color.green);
								if (GUILayout.Button("Lock", GUILayout.Width(45.0f)) == true)
								{
									Repaint();

									paintableTexture.Lock(this);
								}
							P3dHelper.EndColor();
							P3dGroup_Drawer.OnGUI(P3dHelper.Reserve(), paintableTexture);
							paintableTexture.Channel = (P3dChannel)EditorGUILayout.EnumPopup(paintableTexture.Channel);
							P3dHelper.BeginColor(Color.green);
								if (GUILayout.Button("Lock & Paint", GUILayout.Width(85.0f)) == true)
								{
									Repaint();

									if (paintableTexture.Lock(this) == true)
									{
										tab = 2;
									}
								}
							P3dHelper.EndColor();
						EditorGUILayout.EndHorizontal();

						if (paintableTexture.LockFailed == true)
						{
							EditorGUILayout.HelpBox("Failed to lock texture.\nThis may be because the texture is not readable, if so, try cloning it.\nThis may be because the texture format is not readable, if so, try changing the format.", MessageType.Error);
						}
					}
				}
				else
				{
					EditorGUILayout.HelpBox("This texture isn't a Texture2D, so it cannot be painted.", MessageType.Error);
				}
			}
			else
			{
				EditorGUILayout.HelpBox("There is no texture in this slot. Either drag and drop one in, or create one below.", MessageType.Warning);

				createFormat  = (TextureFormat)EditorGUILayout.EnumPopup("Format", createFormat);
				createMipMaps = EditorGUILayout.Toggle("Mip Maps", createMipMaps);
				createLinear  = EditorGUILayout.Toggle("Linear", createLinear);
				createColor   = EditorGUILayout.ColorField("Color", createColor);
				createWidth   = EditorGUILayout.IntField("Width", createWidth);
				createHeight  = EditorGUILayout.IntField("Height", createHeight);

				P3dHelper.BeginColor(Color.green);
					if (GUILayout.Button("Create") == true)
					{
						var newTexture2D = new Texture2D(createWidth, createHeight, createFormat, createMipMaps, createLinear);

						createFailed = true;

						if (CanReadWrite(newTexture2D) == true)
						{
							var pixels32  = new Color32[createWidth * createHeight];
							var color32   = (Color32)createColor;

							for (var i = createWidth * createHeight - 1; i >= 0; i--)
							{
								pixels32[i] = color32;
							}

							newTexture2D.SetPixels32(pixels32);
							newTexture2D.Apply();

							texture      = newTexture2D;
							createFailed = false;
						}
					}
				P3dHelper.EndColor();

				if (createFailed == true)
				{
					EditorGUILayout.HelpBox("Failed to create texture. This means the format you tried to use is not readable, or the size is invalid.", MessageType.Error);
				}
			}

			return texture;
		}
	}
}