using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public static class SecondaryTextureAutoAssigner
{
    private struct TextureImporterData
    {
        public TextureImporterData(Texture2D texture, TextureImporter importer)
        {
            this.Texture = texture;
            this.Importer = importer;
        }
        
        public readonly Texture2D Texture;
        public readonly TextureImporter Importer;
    }

    private struct SecondaryTexturesData
    {
        public TextureImporterData TargetTexture;
        public Dictionary<string, Texture2D> SecondaryTextures;

        public SecondarySpriteTexture[] ToSecondarySpriteTextureArray()
        {
            List<SecondarySpriteTexture> secondarySpriteTextures = new();
            foreach (KeyValuePair<string, Texture2D> secondaryTexture in this.SecondaryTextures)
                secondarySpriteTextures.Add(new SecondarySpriteTexture { name = secondaryTexture.Key, texture = secondaryTexture.Value });
            
            return secondarySpriteTextures.ToArray();
        }
    }
    
    private static readonly string[] SecondaryTexturesNames =
    {
        "_ColorSwapMask",
        "_NormalMap"
    };
    
    [MenuItem("Tools/Secondary Textures Assigner/Auto assign for selected folder")]
    private static void AutoAssignForSelectedFolder()
    {
        if (!TryGetValidSelection(out string path))
            return;

        // Get candidate folders.
        string[] folders = GetFoldersAndSubfoldersRecursively(path);
        FilterFoldersWithoutFiles(ref folders);

        // Parse folders content to gather textures and their importers.
        Dictionary<string, TextureImporterData[]> textureImporterDataPerFolder = new();
        foreach (string folder in folders)
            if (TryComputeTextureImporterDataForFolder(folder, out TextureImporterData[] textureImporterData))
                textureImporterDataPerFolder.Add(folder, textureImporterData);

        // Get together main and secondary textures.
        List<SecondaryTexturesData> secondaryTexturesData = new();
        foreach (KeyValuePair<string, TextureImporterData[]> textureImporterData in textureImporterDataPerFolder)
            secondaryTexturesData.AddRange(ComputeSecondaryTexturesDataForFolder(textureImporterData.Key, textureImporterData.Value));

        // Reimport main textures with their secondary textures.
        secondaryTexturesData.ForEach(AssignSecondaryTextures);
    }

    [MenuItem("Tools/Secondary Textures Assigner/Cleanup for selected folder")]
    private static void CleanupForSelectedFolder()
    {
        if (!TryGetValidSelection(out string path))
            return;
        
        // Get candidate folders.
        string[] folders = GetFoldersAndSubfoldersRecursively(path);
        FilterFoldersWithoutFiles(ref folders);

        // Parse folders content to gather textures and their importers.
        Dictionary<string, TextureImporterData[]> textureImporterDataPerFolder = new();
        foreach (string folder in folders)
            if (TryComputeTextureImporterDataForFolder(folder, out TextureImporterData[] textureImporterData))
                textureImporterDataPerFolder.Add(folder, textureImporterData);

        // Cleanup secondary textures.
        foreach (KeyValuePair<string, TextureImporterData[]> textureImporterData in textureImporterDataPerFolder)
            foreach (TextureImporterData importerData in textureImporterData.Value)
                CleanupSecondaryTextures(importerData.Importer);
    }

    private static bool TryGetValidSelection(out string selectionPath)
    {
        selectionPath = string.Empty;
        Object selectedObject = Selection.activeObject;

        if (selectedObject == null)
        {
            Debug.LogWarning("Selection is null!");
            return false;
        }
        
        selectionPath = AssetDatabase.GetAssetPath(selectedObject.GetInstanceID());

        if (selectionPath.Length <= 0)
        {
            Debug.LogWarning("Selection is not in Assets folder!");
            return false;
        }

        if (!Directory.Exists(selectionPath))
        {
            Debug.LogWarning($"Selection is not a folder (selection path: {selectionPath})!");
            return false;
        }

        return true;
    }
    
    private static string[] GetFoldersAndSubfoldersRecursively(string path, bool includeRoot = true)
    {
        List<string> folders = includeRoot ? new List<string> { path } : new List<string>();
        Directory.GetDirectories(path).ToList().ForEach(o => folders.AddRange(GetFoldersAndSubfoldersRecursively(o)));
        return folders.ToArray();
    }

    private static void FilterFoldersWithoutFiles(ref string[] folders)
    {
        string[] invalidExtensions = { ".meta", ".preset" };
        bool Filter(string folder) => Directory.GetFiles(folder).Any(o => invalidExtensions.All(p => !o.Contains(p)));
        folders = folders.Where(Filter).ToArray();
    }

    private static bool TryComputeTextureImporterDataForFolder(string path, out TextureImporterData[] textureImporterData)
    {
        path = path.Replace("Assets/", "");
        string[] files = Directory.GetFiles($"{Application.dataPath}/{path}");

        System.Collections.Generic.List<TextureImporterData> result = new();
        
        foreach (string file in files)
        {
            string assetLocalPath = file[file.IndexOf("Assets", System.StringComparison.Ordinal)..];
            
            Texture2D texture = AssetDatabase.LoadAssetAtPath(assetLocalPath, typeof(Texture2D)) as Texture2D;
            if (texture == null)
                continue;
            
            TextureImporter importer = AssetImporter.GetAtPath(assetLocalPath) as TextureImporter;
            if (importer == null)
                continue;
            
            result.Add(new TextureImporterData(texture, importer));
        }

        textureImporterData = result.ToArray();
        return textureImporterData.Length > 0;
    }

    private static SecondaryTexturesData[] ComputeSecondaryTexturesDataForFolder(string folder, TextureImporterData[] folderTextures)
    {
        List<SecondaryTexturesData> result = new();

        foreach (TextureImporterData folderTexture in folderTextures)                                // Foreach texture in the folder.
            if (SecondaryTexturesNames.All(o => !folderTexture.Texture.name.Contains(o)))       // If texture is not a secondary texture.
                result.Add(ComputeSecondaryTexturesData(folder, folderTexture, folderTextures)); // Get its secondary textures.

        return result.ToArray();
    }

    private static SecondaryTexturesData ComputeSecondaryTexturesData(string folder, TextureImporterData targetTexture, TextureImporterData[] folderTextures)
    {
        SecondaryTexturesData result = new()
        {
            TargetTexture = targetTexture,
            SecondaryTextures = new Dictionary<string, Texture2D>()
        };
        
        foreach (TextureImporterData folderTexture in folderTextures)                                        // Foreach texture in the folder.
            if (folderTexture.Texture != targetTexture.Texture)                                              // Ignore target texture.
                foreach (string secondaryTextureName in SecondaryTexturesNames)                              // Foreach secondary texture names.
                    if ($"{targetTexture.Texture.name}{secondaryTextureName}" == folderTexture.Texture.name) // If texture's name correspond to a secondary texture.
                        result.SecondaryTextures.Add(secondaryTextureName, folderTexture.Texture);           // Record the name/suffix and the texture.

        return result;
    }

    private static void AssignSecondaryTextures(SecondaryTexturesData secondaryTexturesData)
    {
        TextureImporter importer = secondaryTexturesData.TargetTexture.Importer;
        importer.secondarySpriteTextures = secondaryTexturesData.ToSecondarySpriteTextureArray();
        EditorUtility.SetDirty(importer);
        importer.SaveAndReimport();
    }

    private static void CleanupSecondaryTextures(TextureImporter importer)
    {
        importer.secondarySpriteTextures = null;
        EditorUtility.SetDirty(importer);
        importer.SaveAndReimport();
    }
}
