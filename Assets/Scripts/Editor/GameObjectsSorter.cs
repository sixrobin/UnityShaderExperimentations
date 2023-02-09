namespace RSLib.Editor
{
	using System;
	using UnityEngine;
	using UnityEditor;

	public static class GameObjectsSorter
	{
        private const string SHORTCUT = "%&s";

		[MenuItem("GameObject/Sort by Names " + SHORTCUT, true)]
		private static bool CheckSelectionCount()
		{
			return Selection.gameObjects.Length > 1;
		}

		[MenuItem("GameObject/Sort by Names " + SHORTCUT)]
		public static void SortObjectsByName()
		{
			GameObject[] selection = Selection.gameObjects;
			Array.Sort(selection, (a, b) => a.name.CompareTo(b.name));

			foreach (GameObject go in Selection.gameObjects)
				go.transform.SetSiblingIndex(Array.IndexOf(selection, go));
		}
	}
}