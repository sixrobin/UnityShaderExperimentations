using UnityEngine;

[CreateAssetMenu(fileName = "New Global Shader Variables", menuName = "USB/Global Shader Variables")]
public class GlobalShaderVariables : ScriptableObject
{
    [Header("DEPTH")]
    [SerializeField] private float _depthMultiplier = 1.36f;
    [SerializeField, Range(0.3f, 0.45f)] private float _depthSmoothCenter = 0.4f;
    [SerializeField, Range(0f, 0.01f)] private float _depthSmoothValue = 0.006f;
    
    [Header("CRT")]
    [SerializeField, Range(1f, 30f)] private float _CRTCurvature = 5f;
    [SerializeField, Range(0f, 100f)] private float _CRTVignetteWidth = 100f;
    [SerializeField, Range(0.5f, 3f)] private float _CRTScanlinesMultiplier = 1f;
    [SerializeField] private Vector3 _CRTRBGMultiplier = new Vector3(0.25f, 0.2f, 0.3f);
    
    private static readonly int s_depthMultiplier = Shader.PropertyToID("_DepthMultiplier");
    private static readonly int s_depthSmoothCenter = Shader.PropertyToID("_DepthSmoothCenter");
    private static readonly int s_depthSmoothValue = Shader.PropertyToID("_DepthSmoothValue");
    private static readonly int s_crtCurvature = Shader.PropertyToID("_Curvature");
    private static readonly int s_crtVignetteWidth = Shader.PropertyToID("_VignetteWidth");
    private static readonly int s_crtScanlinesMultiplier = Shader.PropertyToID("_ScanlinesMultiplier");
    private static readonly int s_crtRGBMultiplier = Shader.PropertyToID("_RGBMultiplier");

    private void OnValidate()
    {
        Shader.SetGlobalFloat(s_depthMultiplier, this._depthMultiplier);
        Shader.SetGlobalFloat(s_depthSmoothCenter, this._depthSmoothCenter);
        Shader.SetGlobalFloat(s_depthSmoothValue, this._depthSmoothValue);
        Shader.SetGlobalFloat(s_crtCurvature, this._CRTCurvature);
        Shader.SetGlobalFloat(s_crtVignetteWidth, this._CRTVignetteWidth);
        Shader.SetGlobalFloat(s_crtScanlinesMultiplier, this._CRTScanlinesMultiplier);
        Shader.SetGlobalVector(s_crtRGBMultiplier, this._CRTRBGMultiplier);
    }
}
