using UnityEngine;

namespace PaintIn3D
{
	/// <summary>This allows components like P3dPaintableTexture to call components like P3dPixelCounter.</summary>
	public interface IPaintHandler
	{
		void HandlePaint(P3dPaintableTexture paintableTexture, bool preview);
	}
}