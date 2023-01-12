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

    private void OnValidate()
    {
        Shader.SetGlobalFloat(s_depthMultiplier, this._depthMultiplier);
        Shader.SetGlobalFloat(s_depthSmoothCenter, this._depthSmoothCenter);
        Shader.SetGlobalFloat(s_depthSmoothValue, this._depthSmoothValue);
    }
}
