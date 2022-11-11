using UnityEngine;

namespace PaintIn3D
{
	public abstract class P3dCommand
	{
		public bool      Preview;
		public Matrix4x4 Matrix;

		public abstract Material Material
		{
			get;
		}

		public abstract bool RequireSwap
		{
			get;
		}

		public abstract bool RequireMesh
		{
			get;
		}

		public abstract void Apply();
		public abstract void Pool();
	}
}