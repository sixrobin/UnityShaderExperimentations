namespace RSLib.Editor
{
	using System.IO;
	using UnityEditor;
	using UnityEditor.Presets;

	public class PresetImportPerFolder : AssetPostprocessor
	{
		private void OnPreprocessAsset()
		{
			if (!assetImporter.importSettingsMissing)
            {
                return;
            }

            string path = Path.GetDirectoryName(assetPath);

			while (!string.IsNullOrEmpty(path))
			{
                string[] presetGuids = AssetDatabase.FindAssets("t:Preset", new[] { path });
				foreach (string presetGuid in presetGuids)
				{
					string presetPath = AssetDatabase.GUIDToAssetPath(presetGuid);
					if (Path.GetDirectoryName(presetPath) == path)
						if (AssetDatabase.LoadAssetAtPath<Preset>(presetPath).ApplyTo(assetImporter))
							return;
				}

				path = Path.GetDirectoryName(path);
			}
		}
	}
}