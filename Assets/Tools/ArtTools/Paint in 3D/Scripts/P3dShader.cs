using UnityEngine;
using UnityEngine.Rendering;

namespace PaintIn3D
{
	public static class P3dShader
	{
		public static readonly int BLEND_MODE_COUNT = 8;

		[System.NonSerialized]
		public static int _SrcRGB;

		[System.NonSerialized]
		public static int _DstRGB;

		[System.NonSerialized]
		public static int _SrcA;

		[System.NonSerialized]
		public static int _DstA;

		[System.NonSerialized]
		public static int _Op;

		[System.NonSerialized]
		public static int _Channel;

		[System.NonSerialized]
		public static int _Matrix;

		[System.NonSerialized]
		public static int _Buffer;

		[System.NonSerialized]
		public static int _Direction;

		[System.NonSerialized]
		public static int _Texture;

		[System.NonSerialized]
		public static int _Shape;

		[System.NonSerialized]
		public static int _Strength;

		[System.NonSerialized]
		public static int _Tiling;

		[System.NonSerialized]
		public static int _Color;

		[System.NonSerialized]
		public static int _NormalScale;

		[System.NonSerialized]
		public static int _Hardness;

		[System.NonSerialized]
		public static int _Opacity;

		[System.NonSerialized]
		public static int _KernelSize;

		static P3dShader()
		{
			_SrcRGB = Shader.PropertyToID("_SrcRGB");
			_DstRGB = Shader.PropertyToID("_DstRGB");
			_SrcA   = Shader.PropertyToID("_SrcA");
			_DstA   = Shader.PropertyToID("_DstA");
			_Op     = Shader.PropertyToID("_Op");

			_Channel = Shader.PropertyToID("_Channel");

			_Matrix      = Shader.PropertyToID("_Matrix");
			_Buffer      = Shader.PropertyToID("_Buffer");
			_Direction   = Shader.PropertyToID("_Direction");
			_Texture     = Shader.PropertyToID("_Texture");
			_Shape       = Shader.PropertyToID("_Shape");
			_Strength    = Shader.PropertyToID("_Strength");
			_Tiling      = Shader.PropertyToID("_Tiling");
			_Color       = Shader.PropertyToID("_Color");
			_NormalScale = Shader.PropertyToID("_NormalScale");
			_Hardness    = Shader.PropertyToID("_Hardness");
			_Opacity     = Shader.PropertyToID("_Opacity");
			_KernelSize  = Shader.PropertyToID("_KernelSize");
		}

		public static Shader Load(string shaderName)
		{
			var shader = Shader.Find(shaderName);

			if (shader == null)
			{
				throw new System.Exception("Failed to find shader called: " + shaderName);
			}

			return shader;
		}

		public static Material Build(Shader shader)
		{
			var material = new Material(shader);
#if UNITY_EDITOR
			material.hideFlags = HideFlags.DontSave;
#endif
			return material;
		}

		public static Material Build(Shader shader, int uv, P3dBlendMode blendMode)
		{
			var material = Build(shader);

			switch (blendMode)
			{
				case P3dBlendMode.AlphaBlend:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.SrcAlpha);
					material.SetInt(_DstRGB, (int)BlendMode.OneMinusSrcAlpha);
					material.SetInt(_SrcA, (int)BlendMode.OneMinusDstAlpha);
					material.SetInt(_DstA, (int)BlendMode.One);
					material.SetInt(_Op, (int)BlendOp.Add);
				}
				break;

				case P3dBlendMode.AlphaBlendRGB:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.SrcAlpha);
					material.SetInt(_DstRGB, (int)BlendMode.OneMinusSrcAlpha);
					material.SetInt(_SrcA, (int)BlendMode.Zero);
					material.SetInt(_DstA, (int)BlendMode.One);
					material.SetInt(_Op, (int)BlendOp.Add);
				}
				break;

				case P3dBlendMode.Additive:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.One);
					material.SetInt(_DstRGB, (int)BlendMode.One);
					material.SetInt(_SrcA, (int)BlendMode.One);
					material.SetInt(_DstA, (int)BlendMode.One);
					material.SetInt(_Op, (int)BlendOp.Add);
					material.EnableKeyword("P3D_A"); // Additive
				}
				break;

				case P3dBlendMode.Subtractive:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.One);
					material.SetInt(_DstRGB, (int)BlendMode.One);
					material.SetInt(_SrcA, (int)BlendMode.One);
					material.SetInt(_DstA, (int)BlendMode.One);
					material.SetInt(_Op, (int)BlendOp.ReverseSubtract);
					material.EnableKeyword("P3D_A"); // Additive
				}
				break;

				case P3dBlendMode.SoftAdditive:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.OneMinusDstColor);
					material.SetInt(_DstRGB, (int)BlendMode.One);
					material.SetInt(_SrcA, (int)BlendMode.OneMinusDstAlpha);
					material.SetInt(_DstA, (int)BlendMode.One);
					material.SetInt(_Op, (int)BlendOp.Add);
					material.EnableKeyword("P3D_A"); // Additive
				}
				break;

				case P3dBlendMode.AlphaBlendAdvanced:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.One);
					material.SetInt(_DstRGB, (int)BlendMode.Zero);
					material.SetInt(_SrcA, (int)BlendMode.One);
					material.SetInt(_DstA, (int)BlendMode.Zero);
					material.SetInt(_Op, (int)BlendOp.Add);
					material.EnableKeyword("P3D_B"); // Swapped alpha
				}
				break;

				case P3dBlendMode.Replace:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.One);
					material.SetInt(_DstRGB, (int)BlendMode.Zero);
					material.SetInt(_SrcA, (int)BlendMode.One);
					material.SetInt(_DstA, (int)BlendMode.Zero);
					material.SetInt(_Op, (int)BlendOp.Add);
					material.EnableKeyword("P3D_C"); // Shape
				}
				break;

				case P3dBlendMode.Multiply:
				{
					material.SetInt(_SrcRGB, (int)BlendMode.DstColor);
					material.SetInt(_DstRGB, (int)BlendMode.Zero);
					material.SetInt(_SrcA, (int)BlendMode.One);
					material.SetInt(_DstA, (int)BlendMode.Zero);
					material.SetInt(_Op, (int)BlendOp.Add);
					material.EnableKeyword("P3D_D"); // Multiply
				}
				break;
			}

			return material;
		}
	}
}