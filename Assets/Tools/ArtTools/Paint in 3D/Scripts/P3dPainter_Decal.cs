using UnityEngine;
using System.Collections.Generic;

namespace PaintIn3D
{
	public static partial class P3dPainter
	{
		public class Decal : P3dCommand
		{
			[System.NonSerialized]
			private static Material[] cachedMaterials;

			[System.NonSerialized]
			private static bool[] cachedSwaps;

			[System.NonSerialized]
			private static Material cachedMaterial;

			[System.NonSerialized]
			private static bool cachedSwap;

			[System.NonSerialized]
			private static Matrix4x4 cachedMatrix = Matrix4x4.identity;

			[System.NonSerialized]
			private static Vector3 cachedPosition;

			[System.NonSerialized]
			private static float cachedSqrRadius;

			[System.NonSerialized]
			private static Vector3 cachedDirection;

			[System.NonSerialized]
			private static Texture cachedTexture;

			[System.NonSerialized]
			private static Texture cachedShape;

			[System.NonSerialized]
			private static float cachedHardness;

			[System.NonSerialized]
			private static float cachedNormalScale;

			[System.NonSerialized]
			private static Color cachedColor;

			[System.NonSerialized]
			private static float cachedOpacity;

			[System.NonSerialized]
			private Material material;

			[System.NonSerialized]
			private bool swap;

			[System.NonSerialized]
			private Matrix4x4 matrix;

			[System.NonSerialized]
			private Vector3 direction;

			[System.NonSerialized]
			private Texture texture;

			[System.NonSerialized]
			private Texture shape;

			[System.NonSerialized]
			private float hardness;

			[System.NonSerialized]
			private float normalScale;

			[System.NonSerialized]
			private Color color;

			[System.NonSerialized]
			private float opacity;

			public override Material Material
			{
				get
				{
					return material;
				}
			}

			public override bool RequireSwap
			{
				get
				{
					return swap;
				}
			}

			public override bool RequireMesh
			{
				get
				{
					return true;
				}
			}

			static Decal()
			{
				cachedMaterials = BuildMaterialsBlendModes("Hidden/Paint in 3D/Decal");
				cachedSwaps     = BuildSwapBlendModes();
			}

			public static void SetMatrix(Vector3 position, Vector3 normal, float angle, float size, Texture decal, float depth, bool mirror)
			{
				var rotation = P3dHelper.NormalToCameraRotation(normal);

				SetMatrix(position, rotation, angle, size, decal, depth, mirror);
			}

			public static void SetMatrix(Vector3 position, Quaternion rotation, float angle, Vector2 size, Texture decal, float depth, bool mirror)
			{
				if (mirror == true)
				{
					size.x = -size.x;
				}

				SetMatrix(position, rotation, angle, new Vector3(size.x, size.y, depth));
			}

			public static void SetMatrix(Vector3 position, Quaternion rotation, float angle, float size, Texture decal, float depth, bool mirror)
			{
				var width  = size;
				var height = size;

				if (decal != null)
				{
					if (decal.width > decal.height)
					{
						height *= decal.height / (float)decal.width;
					}
					else
					{
						width *= decal.width / (float)decal.height;
					}

					if (mirror == true)
					{
						width = -width;
					}
				}

				SetMatrix(position, rotation, angle, new Vector3(width, height, depth));
			}

			public static void SetMatrix(Vector3 position, Quaternion rotation, float angle, Vector3 size)
			{
				var up     = Vector3.up;
				var camera = P3dHelper.GetCamera();

				if (camera != null)
				{
					up = camera.transform.up;
				}

				//cachedMatrix    = Matrix4x4.Translate(position) * Matrix4x4.Rotate(rotation * Quaternion.Euler(0.0f, 0.0f, angle)) * Matrix4x4.Scale(size);
				cachedMatrix    = Matrix4x4.TRS(position, rotation * Quaternion.Euler(0.0f, 0.0f, angle), size);
				cachedPosition  = position;
				cachedSqrRadius = (size * 0.5f).sqrMagnitude;
				cachedDirection = rotation * Vector3.forward;
			}

			public static void SetMaterial(P3dBlendMode blendMode, Texture decal, float hardness, float oneSided, Color color, float opacity, Texture shape)
			{
				cachedMaterial    = cachedMaterials[(int)blendMode];
				cachedSwap        = cachedSwaps[(int)blendMode];
				cachedColor       = color;
				cachedOpacity     = opacity;
				cachedHardness    = hardness;
				cachedTexture     = decal;
				cachedShape       = shape;
				cachedNormalScale = oneSided;
			}

			public static void SubmitAll(bool preview = false, int layerMask = -1, int groupMask = -1)
			{
				var paintables = P3dPaintable.FindOverlap(cachedPosition, cachedSqrRadius, layerMask);

				for (var i = paintables.Count - 1; i >= 0; i--)
				{
					var paintableTextures = P3dPaintableTexture.Filter(paintables[i], groupMask);

					for (var j = paintableTextures.Count - 1; j >= 0; j--)
					{
						Submit(paintableTextures[j], preview);
					}
				}
			}

			public static void ApplyStatic(P3dChannel channel)
			{
				cachedMaterial.SetMatrix(P3dShader._Matrix, cachedMatrix.inverse);
				cachedMaterial.SetVector(P3dShader._Direction, cachedDirection);
				cachedMaterial.SetColor(P3dShader._Color, cachedColor);
				cachedMaterial.SetFloat(P3dShader._Opacity, cachedOpacity);
				cachedMaterial.SetFloat(P3dShader._Hardness, cachedHardness);
				cachedMaterial.SetTexture(P3dShader._Texture, cachedTexture);
				cachedMaterial.SetTexture(P3dShader._Shape, cachedShape);
				cachedMaterial.SetFloat(P3dShader._NormalScale, cachedNormalScale);
			}

			public override void Apply()
			{
				material.SetMatrix(P3dShader._Matrix, matrix.inverse);
				material.SetVector(P3dShader._Direction, direction);
				material.SetColor(P3dShader._Color, color);
				material.SetFloat(P3dShader._Opacity, opacity);
				material.SetFloat(P3dShader._Hardness, hardness);
				material.SetTexture(P3dShader._Texture, texture);
				material.SetTexture(P3dShader._Shape, shape);
				material.SetFloat(P3dShader._NormalScale, normalScale);
			}

			public override void Pool()
			{
				pool.Add(this); poolCount++;
			}

			public static void CopyTo(Decal command)
			{
				command.material    = cachedMaterial;
				command.swap        = cachedSwap;
				command.matrix      = cachedMatrix;
				command.direction   = cachedDirection;
				command.color       = cachedColor;
				command.opacity     = cachedOpacity;
				command.hardness    = cachedHardness;
				command.texture     = cachedTexture;
				command.shape       = cachedShape;
				command.normalScale = cachedNormalScale;
			}

			public static void Submit(P3dPaintableTexture paintableTexture, bool preview)
			{
				var command = paintableTexture.AddCommand(pool, ref poolCount, preview);

				CopyTo(command);
			}

			private static int poolCount;

			private static List<Decal> pool = new List<Decal>();
		}
	}
}