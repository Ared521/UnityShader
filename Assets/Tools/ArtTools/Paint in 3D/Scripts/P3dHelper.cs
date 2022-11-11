using UnityEngine;
using System.Collections.Generic;

namespace PaintIn3D
{
	public static partial class P3dHelper
	{
		public const string HelpUrlPrefix = "https://bitbucket.org/Darkcoder/paint-in-3d/wiki/";

		public const string ComponentMenuPrefix = "Paint in 3D/P3D ";

		public static Quaternion NormalToCameraRotation(Vector3 normal, Camera optionalCamera = null)
		{
			var up     = Vector3.up;
			var camera = GetCamera(optionalCamera);

			if (camera != null)
			{
				up = camera.transform.up;
			}

			return Quaternion.LookRotation(-normal, up);
		}

		// Return the current camera, or the main camera
		public static Camera GetCamera(Camera camera = null)
		{
			if (camera == null || camera.isActiveAndEnabled == false)
			{
				camera = Camera.main;
			}

			return camera;
		}

		public static bool IndexInMask(int index, LayerMask mask)
		{
			mask &= 1 << index;

			return mask != 0;
		}

		public static bool CanReadPixels(TextureFormat format)
		{
			if (format == TextureFormat.RGBA32 || format == TextureFormat.ARGB32 || format == TextureFormat.RGB24 || format == TextureFormat.RGBAFloat || format == TextureFormat.RGBAHalf)
			{
				return true;
			}

			return false;
		}

		public static void ReadPixels(Texture2D texture2D, RenderTexture renderTexture)
		{
			var oldActive = RenderTexture.active;

			RenderTexture.active = renderTexture;

			if (CanReadPixels(texture2D.format) == true)
			{
				texture2D.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);

				RenderTexture.active = oldActive;

				texture2D.Apply();
			}
			else
			{
				var buffer = new Texture2D(renderTexture.width, renderTexture.height, TextureFormat.ARGB32, false);

				buffer.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);

				RenderTexture.active = oldActive;

				var pixels = buffer.GetPixels32();

				Object.DestroyImmediate(buffer);

				texture2D.SetPixels32(pixels);
				texture2D.Apply();
			}
		}

		public static bool Downsample(RenderTexture renderTexture, int steps, ref RenderTexture temporary)
		{
			if (steps > 0 && renderTexture != null)
			{
				// Perform initial downsample to get buffer
				var oldActive         = RenderTexture.active;
				var width             = renderTexture.width  / 2;
				var height            = renderTexture.height / 2;
				var depth             = renderTexture.depth;
				var format            = renderTexture.format;
				var halfRenderTexture = GetRenderTexture(width, height, depth, format);

				Graphics.Blit(renderTexture, halfRenderTexture);

				// Ping pong downsamples
				for (var i = 1; i < steps; i++)
				{
					width            /= 2;
					height           /= 2;
					renderTexture     = halfRenderTexture;
					halfRenderTexture = GetRenderTexture(width, height, depth, format);

					Graphics.Blit(renderTexture, halfRenderTexture);

					ReleaseRenderTexture(renderTexture);
				}

				temporary = halfRenderTexture;

				RenderTexture.active = oldActive;

				return true;
			}

			return false;
		}

		public static Texture2D GetReadableTexture(Texture texture, TextureFormat format = TextureFormat.ARGB32, bool mipMaps = false, int width = 0, int height = 0)
		{
			var newTexture = default(Texture2D);

			if (texture != null)
			{
				if (width <= 0)
				{
					width = texture.width;
				}

				if (height <= 0)
				{
					height = texture.height;
				}

				if (CanReadPixels(format) == true)
				{
					var oldActive     = RenderTexture.active;
					var renderTexture = GetRenderTexture(width, height, 0, RenderTextureFormat.ARGB32);

					newTexture = new Texture2D(width, height, format, mipMaps);

					Graphics.Blit(texture, renderTexture);

					RenderTexture.active = renderTexture;

					newTexture.ReadPixels(new Rect(0, 0, width, height), 0, 0);

					RenderTexture.active = oldActive;

					ReleaseRenderTexture(renderTexture);

					newTexture.Apply();
				}
			}

			return newTexture;
		}

		public static void SavePngTextureData(byte[] pngData, string saveName, bool save = true)
		{
			if (pngData != null)
			{
				var base64 = System.Convert.ToBase64String(pngData);

				PlayerPrefs.SetString(saveName, base64);

				if (save == true)
				{
					PlayerPrefs.Save();
				}
			}
		}

		public static bool TryLoadTexture(string saveName, ref Texture2D texture2D)
		{
			if (PlayerPrefs.HasKey(saveName) == true)
			{
				var base64 = PlayerPrefs.GetString(saveName);

				if (string.IsNullOrEmpty(base64) == false)
				{
					var data = System.Convert.FromBase64String(base64);

					if (data != null && data.Length > 0)
					{
						if (texture2D == null)
						{
							texture2D = new Texture2D(1, 1, TextureFormat.ARGB32, false);
						}

						texture2D.LoadImage(data, true);

						return true;
					}
				}
			}

			return false;
		}

		public static RenderTexture GetRenderTexture(int width, int height, int depth, RenderTextureFormat format)
		{
			return RenderTexture.GetTemporary(width, height, depth, format, RenderTextureReadWrite.Linear);
		}

		public static void ReleaseRenderTexture(RenderTexture renderTexture)
		{
			RenderTexture.ReleaseTemporary(renderTexture);
		}

		public static void Blit(RenderTexture renderTexture, Texture other)
		{
			var oldActive = RenderTexture.active;

			Graphics.Blit(other, renderTexture);

			RenderTexture.active = oldActive;
		}

		public static void Blit(RenderTexture renderTexture, Material material)
		{
			var oldActive = RenderTexture.active;

			Graphics.Blit(default(Texture), renderTexture, material);

			RenderTexture.active = oldActive;
		}

		public static bool TextureExists(string saveName)
		{
			return PlayerPrefs.HasKey(saveName);
		}

		public static void ClearTexture(string saveName, bool save = true)
		{
			if (PlayerPrefs.HasKey(saveName) == true)
			{
				PlayerPrefs.DeleteKey(saveName);

				if (save == true)
				{
					PlayerPrefs.Save();
				}
			}
		}

		public static Texture2D CreateTexture(int width, int height, TextureFormat format, bool mipMaps)
		{
			if (width > 0 && height > 0)
			{
				return new Texture2D(width, height, format, mipMaps);
			}

			return null;
		}

		// This method allows you to easily find a Material attached to a GameObject
		public static Material GetMaterial(GameObject gameObject, int materialIndex = 0)
		{
			if (gameObject != null && materialIndex >= 0)
			{
				var renderer = gameObject.GetComponent<Renderer>();

				if (renderer != null)
				{
					var materials = renderer.sharedMaterials;

					if (materialIndex < materials.Length)
					{
						return materials[materialIndex];
					}
				}
			}

			return null;
		}

		// This method allows you to easily duplicate a Material attached to a GameObject
		public static Material CloneMaterial(GameObject gameObject, int materialIndex = 0)
		{
			if (gameObject != null && materialIndex >= 0)
			{
				var renderer = gameObject.GetComponent<Renderer>();

				if (renderer != null)
				{
					var materials = renderer.sharedMaterials;

					if (materialIndex < materials.Length)
					{
						// Get existing material
						var material = materials[materialIndex];

						// Clone it
						material = Object.Instantiate(material);

						// Update array
						materials[materialIndex] = material;

						// Update materials
						renderer.sharedMaterials = materials;

						return material;
					}
				}
			}

			return null;
		}

		// This method allows you to add a material (layer) to a renderer at the specified material index, or -1 for the end (top)
		public static Material AddMaterial(Renderer renderer, Shader shader, int materialIndex = -1)
		{
			if (renderer != null)
			{
				var newMaterials = new List<Material>(renderer.sharedMaterials);
				var newMaterial  = new Material(shader);

				if (materialIndex <= 0)
				{
					materialIndex = newMaterials.Count;
				}

				newMaterials.Insert(materialIndex, newMaterial);

				renderer.sharedMaterials = newMaterials.ToArray();

				return newMaterial;
			}

			return null;
		}

		public static float Reciprocal(float a)
		{
			return a != 0.0f ? 1.0f / a : 0.0f;
		}

		public static int Mod(int a, int b)
		{
			var m = a % b;

			if (m < 0)
			{
				return m + b;
			}

			return m;
		}

		public static Vector3 Reciprocal3(Vector3 xyz)
		{
			xyz.x = Reciprocal(xyz.x);
			xyz.y = Reciprocal(xyz.y);
			xyz.z = Reciprocal(xyz.z);

			return xyz;
		}

		public static float DampenFactor(float dampening, float elapsed)
		{
#if UNITY_EDITOR
			if (Application.isPlaying == false)
			{
				return 1.0f;
			}
#endif
			return 1.0f - Mathf.Pow((float)System.Math.E, -dampening * elapsed);
		}

		// This allows you to destroy a UnityEngine.Object in edit or play mode
		public static T Destroy<T>(T o)
			where T : Object
		{
#if UNITY_EDITOR
			if (Application.isPlaying == false)
			{
				Object.DestroyImmediate(o, true); return null;
			}
#endif

			Object.Destroy(o);

			return null;
		}
	}
}