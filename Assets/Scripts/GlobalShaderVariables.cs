using UnityEngine;

[CreateAssetMenu(fileName = "New Global Shader Variables", menuName = "USB/Global Shader Variables")]
public class GlobalShaderVariables : ScriptableObject
{
    [Header("DEPTH")]
    [SerializeField] private float _depthMultiplier = 1.36f;
    [SerializeField, Range(0.3f, 0.45f)] private float _depthSmoothCenter = 0.4f;
    [SerializeField, Range(0f, 0.01f)] private float _depthSmoothValue = 0.006f;
    
    private static readonly int s_depthMultiplier = Shader.PropertyToID("_DepthMultiplier");
    private static readonly int s_depthSmoothCenter = Shader.PropertyToID("_DepthSmoothCenter");
    private static readonly int s_depthSmoothValue = Shader.PropertyToID("_DepthSmoothValue");

    private static System.Collections.Generic.List<T> FindAssetsByType<T>() where T : UnityEngine.Object
    {
        System.Collections.Generic.List<T> assets = new();
        string[] guids = UnityEditor.AssetDatabase.FindAssets($"t:{typeof(T)}");
        
        for (int i = 0; i < guids.Length; ++i)
        {
            string assetPath = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i]);
            T asset = UnityEditor.AssetDatabase.LoadAssetAtPath<T>(assetPath);
            if (asset != null)
                assets.Add(asset);
        }
        
        return assets;
    }

    #if UNITY_EDITOR
    [UnityEditor.InitializeOnLoadMethod]
    #endif
    private static void OnLoad()
    {
        System.Collections.Generic.List<GlobalShaderVariables> assets = FindAssetsByType<GlobalShaderVariables>();

        if (assets.Count == 0)
        {
            Debug.LogWarning($"No instance of type {nameof(GlobalShaderVariables)} has been found.");
            return;
        }
        
        if (assets.Count > 1)
        {
            Debug.LogError($"More than 1 instance of type {nameof(GlobalShaderVariables)} have been found.");
            return;
        }
        
        assets[0].UpdateValues();
    }
    
    private void UpdateValues()
    {
        Shader.SetGlobalFloat(s_depthMultiplier, this._depthMultiplier);
        Shader.SetGlobalFloat(s_depthSmoothCenter, this._depthSmoothCenter);
        Shader.SetGlobalFloat(s_depthSmoothValue, this._depthSmoothValue);
    }

    private void OnValidate()
    {
        this.UpdateValues();
    }
}
