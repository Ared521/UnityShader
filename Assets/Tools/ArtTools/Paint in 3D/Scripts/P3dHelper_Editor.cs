#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public static partial class P3dHelper
	{
		private static List<Color> colors = new List<Color>();

		public static void ClearColors()
		{
			colors.Clear();
		}

		public static void BeginColor(bool error = true)
		{
			colors.Add(GUI.color);

			GUI.color = error == true ? Color.red : colors[0];
		}

		public static void BeginColor(Color color)
		{
			colors.Add(GUI.color);

			GUI.color = color;
		}

		public static void EndColor()
		{
			var index = colors.Count - 1;

			GUI.color = colors[index];

			colors.RemoveAt(index);
		}
	
		public static void SetDirty(Object target)
		{
			if (Application.isEditor == false)
			{
				UnityEditor.EditorUtility.SetDirty(target);

#if UNITY_4 || UNITY_5_0 || UNITY_5_1 || UNITY_5_2
				UnityEditor.EditorApplication.MarkSceneDirty();
#else
				UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
#endif
			}
		}
	
		public static T GetAssetImporter<T>(Object asset)
			where T : AssetImporter
		{
			return GetAssetImporter<T>((AssetDatabase.GetAssetPath(asset)));
		}
	
		public static T GetAssetImporter<T>(string path)
			where T : AssetImporter
		{
			return AssetImporter.GetAtPath(path) as T;
		}
	
		public static string SaveDialog(string title, string directory, string defaultName, string extension)
		{
			var path = EditorUtility.SaveFilePanel(title, directory, defaultName, extension);
		
			if (path.StartsWith(Application.dataPath) == true)
			{
				path = "Assets" + path.Substring(Application.dataPath.Length);
			}
		
			return path;
		}
	
		public static void ReimportAsset(Object asset)
		{
			ReimportAsset(AssetDatabase.GetAssetPath(asset));
		}
	
		public static void ReimportAsset(string path)
		{
			AssetDatabase.ImportAsset(path);
		}
	
		public static bool IsAsset(Object o)
		{
			return o != null && string.IsNullOrEmpty(UnityEditor.AssetDatabase.GetAssetPath(o)) == false;
		}
	
		public static Rect Reserve(float height = 16.0f)
		{
			var rect = default(Rect);

			rect = EditorGUILayout.BeginVertical();
			{
				EditorGUILayout.LabelField(string.Empty, GUILayout.Height(height), GUILayout.ExpandWidth(true), GUILayout.MinWidth(0.0f));
			}
			EditorGUILayout.EndVertical();
		
			return rect;
		}

		public static bool TexEnvNameExists(Material material, string name)
		{
			if (material != null)
			{
				var shader = material.shader;
			
				if (shader != null)
				{
					var count = ShaderUtil.GetPropertyCount(shader);
				
					for (var i = 0; i < count; i++)
					{
						if (ShaderUtil.GetPropertyType(shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
						{
							if (ShaderUtil.GetPropertyName(shader, i) == name)
							{
								return true;
							}
						}
					}
				}
			}

			return false;
		}

		public struct TexEnv
		{
			public string Name;
			public string Desc;
		}

		private static List<TexEnv> texEnvNames = new List<TexEnv>();
	
		public static List<TexEnv> GetTexEnvs(Material material)
		{
			texEnvNames.Clear();

			if (material != null)
			{
				var shader = material.shader;

				if (shader != null)
				{
					var count = ShaderUtil.GetPropertyCount(shader);

					for (var i = 0; i < count; i++)
					{
						if (ShaderUtil.GetPropertyType(shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
						{
							var texEnv = default(TexEnv);

							texEnv.Name = ShaderUtil.GetPropertyName(shader, i);
							texEnv.Desc = ShaderUtil.GetPropertyDescription(shader, i);

							texEnvNames.Add(texEnv);
						}
					}
				}
			}

			return texEnvNames;
		}

		public static Texture[] CopyTextures(Material material)
		{
			var texEnvs  = GetTexEnvs(material);
			var textures = new Texture[texEnvNames.Count];

			for (var i = texEnvNames.Count - 1; i >= 0; i--)
			{
				textures[i] = material.GetTexture(texEnvs[i].Name);
			}

			return textures;
		}

		public static void PasteTextures(Material material, Texture[] textures)
		{
			var texEnvs = GetTexEnvs(material);

			for (var i = texEnvNames.Count - 1; i >= 0; i--)
			{
				material.SetTexture(texEnvs[i].Name, textures[i]);
			}
		}

		public static void SaveTextureAsset(Texture texture, string path, bool overwrite = false)
		{
			var texture2D = GetReadableTexture(texture, TextureFormat.ARGB32, false);
			var bytes     = texture2D.EncodeToPNG();

			Destroy(texture2D);

			var fs = new System.IO.FileStream(path, overwrite == true ? System.IO.FileMode.Create : System.IO.FileMode.CreateNew);
			var bw = new System.IO.BinaryWriter(fs);

			bw.Write(bytes);

			bw.Close();
			fs.Close();

			ReimportAsset(path);
		}
	}
}
#endif