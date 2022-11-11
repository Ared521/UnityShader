using UnityEngine;

namespace PaintIn3D
{
	/// <summary>This component allows you to manage undo/redo states on all P3dPaintableTextures in your scene.</summary>
	public static class P3dStateManager
	{
		public static bool CanUndo
		{
			get
			{
				var paintableTexture = P3dPaintableTexture.FirstInstance;

				for (var i = 0; i < P3dPaintableTexture.InstanceCount; i++)
				{
					if (paintableTexture.CanUndo == true)
					{
						return true;
					}

					paintableTexture = paintableTexture.NextInstance;
				}

				return false;
			}
		}

		public static bool CanRedo
		{
			get
			{
				var paintableTexture = P3dPaintableTexture.FirstInstance;

				for (var i = 0; i < P3dPaintableTexture.InstanceCount; i++)
				{
					if (paintableTexture.CanRedo == true)
					{
						return true;
					}

					paintableTexture = paintableTexture.NextInstance;
				}

				return false;
			}
		}

		/// <summary>This method will call StoreState on all active and enabled P3dPaintableTextures.</summary>
		public static void StoreAllStates()
		{
			var paintableTexture = P3dPaintableTexture.FirstInstance;

			for (var i = 0; i < P3dPaintableTexture.InstanceCount; i++)
			{
				paintableTexture.StoreState();

				paintableTexture = paintableTexture.NextInstance;
			}
		}

		/// <summary>This method will call StoreState on all active and enabled P3dPaintableTextures.</summary>
		public static void ClearAllStates()
		{
			var paintableTexture = P3dPaintableTexture.FirstInstance;

			for (var i = 0; i < P3dPaintableTexture.InstanceCount; i++)
			{
				paintableTexture.ClearStates();

				paintableTexture = paintableTexture.NextInstance;
			}
		}

		/// <summary>This method will call Undo on all active and enabled P3dPaintableTextures.</summary>
		public static void UndoAll()
		{
			var paintableTexture = P3dPaintableTexture.FirstInstance;

			for (var i = 0; i < P3dPaintableTexture.InstanceCount; i++)
			{
				paintableTexture.Undo();

				paintableTexture = paintableTexture.NextInstance;
			}
		}

		/// <summary>This method will call Redo on all active and enabled P3dPaintableTextures.</summary>
		public static void RedoAll()
		{
			var paintableTexture = P3dPaintableTexture.FirstInstance;

			for (var i = 0; i < P3dPaintableTexture.InstanceCount; i++)
			{
				paintableTexture.Redo();

				paintableTexture = paintableTexture.NextInstance;
			}
		}
	}
}