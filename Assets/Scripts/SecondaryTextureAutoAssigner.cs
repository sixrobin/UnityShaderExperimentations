using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;

public static class SecondaryTextureAutoAssigner
{
    [MenuItem("Tools/Auto assign color swap masks")]
    private static void Test()
    {
        string path = string.Empty;
        Object selectedObject = Selection.activeObject;

        if (selectedObject == null)
        {
            Debug.LogWarning("No selection!");
            return;
        }
        
        path = AssetDatabase.GetAssetPath(selectedObject.GetInstanceID());

        if (path.Length <= 0)
        {
            Debug.LogWarning("Selection not in assets folder!");
            return;
        }
        
        if (Directory.Exists(path))
        {
            Debug.Log($"Folder ({path}).");
            
            TextureData[] texturesData = GetAssetsAtPath(path);
            AssignColorSwapMasks(texturesData);

            foreach (string subfolder in Directory.GetDirectories(path))
            {
                TextureData[] subfolderTexturesData = GetAssetsAtPath(subfolder);
                AssignColorSwapMasks(subfolderTexturesData);
            }
        }
        else
        {
            Debug.Log($"File ({path}).");
        }
    }

    private static void AssignColorSwapMasks(TextureData[] texturesData)
    {
        const string colorSwapMaskSuffix = "_ColorSwapMask";
        System.Collections.Generic.Dictionary<TextureImporter, Texture2D> texturesMasks = new();

        foreach (TextureData textureData in texturesData)
        {
            if (textureData.Texture.name.Contains(colorSwapMaskSuffix))
                continue;
            
            texturesMasks.Add(textureData.Importer, texturesData.FirstOrDefault(o => o.Texture.name == $"{textureData.Texture.name}{colorSwapMaskSuffix}").Texture);
        }

        foreach ((TextureImporter importer, Texture2D texture) in texturesMasks)
        {
            SecondarySpriteTexture[] secondarySpriteTextures =
            {
                new()
                {
                    name = "_ColorSwapMask",
                    texture = texture
                }
            };
            
            importer.secondarySpriteTextures = secondarySpriteTextures;
            EditorUtility.SetDirty(importer);
            importer.SaveAndReimport();
        }
    }

    private struct TextureData
    {
        public Texture2D Texture;
        public TextureImporter Importer;
    }
    
    private static TextureData[] GetAssetsAtPath(string path)
    {
        path = path.Remove(0, 7);

        System.Collections.Generic.List<TextureData> result = new();
        
        string[] fileEntries = Directory.GetFiles(Application.dataPath + "/" + path);
        
        foreach (string fileEntry in fileEntries)
        {
            int assetsIndex = fileEntry.IndexOf("Assets", System.StringComparison.Ordinal);
            string localPath = fileEntry[assetsIndex..];

            Texture2D asset = AssetDatabase.LoadAssetAtPath(localPath, typeof(Texture2D)) as Texture2D;
            TextureImporter importer = AssetImporter.GetAtPath(localPath) as TextureImporter;
            
            if (asset != null && importer != null)
            {
                result.Add(new TextureData
                {
                    Texture = asset,
                    Importer = importer
                });
            }
        }
           
        return result.ToArray();
    }
}
