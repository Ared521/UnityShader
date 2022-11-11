using UnityEngine;

namespace PaintIn3D
{
	[System.Serializable]
	public struct P3dGroup
	{
		[SerializeField]
		private int index;

		public P3dGroup(int newIndex)
		{
			if (newIndex <= 0)
			{
				index = 0;
			}
			else if (newIndex >= 31)
			{
				index = 31;
			}
			else
			{
				index = newIndex;
			}
		}

		public static implicit operator int(P3dGroup group)
		{
			return group.index;
		}

		public static implicit operator P3dGroup(int index)
		{
			return new P3dGroup(index);
		}

		public override string ToString()
		{
			return index.ToString();
		}
	}
}