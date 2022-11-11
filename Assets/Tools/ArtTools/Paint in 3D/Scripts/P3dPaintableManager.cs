using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;

namespace PaintIn3D
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(P3dPaintableManager))]
	public class P3dPaintableManager_Editor : P3dEditor<P3dPaintableManager>
	{
		[InitializeOnLoad]
		public class ExecutionOrder
		{
			static ExecutionOrder()
			{
				ForceExecutionOrder(100);
			}
		}

		protected override void OnInspector()
		{
		}
	}
}
#endif

namespace PaintIn3D
{
	[DisallowMultipleComponent]
	[HelpURL(P3dHelper.HelpUrlPrefix + "P3dPaintableManager")]
	public class P3dPaintableManager : P3dLinkedBehaviour<P3dPaintableManager>
	{
		protected virtual void LateUpdate()
		{
			if (this == FirstInstance && P3dPaintable.InstanceCount > 0)
			{
				var paintable = P3dPaintable.FirstInstance;

				for (var i = 0; i < P3dPaintable.InstanceCount; i++)
				{
					paintable.UpdateFromManager();

					paintable = paintable.NextInstance;
				}
			}
			else
			{
				P3dHelper.Destroy(gameObject);
			}
		}
	}
}