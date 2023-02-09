using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;

public static class SecondaryTextureAutoAssigner
{
    [MenuItem("USB/Auto assign color swap masks")]
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

            System.Collections.Generic.IEnumerable<Texture2D> textures = GetAssetsAtPath<Texture2D>(path);
            AssignColorSwapMasks(textures.ToArray());
        }
        else
        {
            Debug.Log($"File ({path}).");
        }
    }

    private static void AssignColorSwapMasks(Texture2D[] textures)
    {
        const string colorSwapMaskSuffix = "_ColorSwapMask";
        System.Collections.Generic.Dictionary<Texture2D, Texture2D> texturesMasks = new();
        
        foreach (Texture2D texture in textures)
            if (!texture.name.Contains(colorSwapMaskSuffix))
                texturesMasks.Add(texture, textures.FirstOrDefault(o => o.name == $"{texture.name}{colorSwapMaskSuffix}"));

        foreach (System.Collections.Generic.KeyValuePair<Texture2D, Texture2D> textureMask in texturesMasks)
        {
            // TODO: Bind texture and color swap mask.
        }
    }
    
    private static System.Collections.Generic.IEnumerable<T> GetAssetsAtPath<T>(string path) where T : Object
    {
        path = path.Remove(0, 7);
        
        System.Collections.ArrayList arrayList = new();
        string[] fileEntries = Directory.GetFiles(Application.dataPath + "/" + path);
        
        foreach (string fileEntry in fileEntries)
        {
            int assetsIndex = fileEntry.IndexOf("Assets", System.StringComparison.Ordinal);
            string localPath = fileEntry[assetsIndex..];

            T asset = (T)AssetDatabase.LoadAssetAtPath(localPath, typeof(T));
 
            TextureImporter importer = AssetImporter.GetAtPath(localPath) as TextureImporter;
            if (importer != null)
            {
                Debug.LogError(importer.name, importer);
            }
            
            if (asset != null)
                arrayList.Add(asset);
        }
        
        T[] result = new T[arrayList.Count];
        
        for (int i = 0; i < arrayList.Count; ++i)
            result[i] = (T)arrayList[i];
           
        return result;
    }
}
