using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CameraCRT : MonoBehaviour
{
    [Header("SHADER")]
    [SerializeField] private Shader _shader = null;

    [Header("DATA")]
    [SerializeField, Range(1f, 30f)] private float _curvature = 8f;
    [SerializeField, Range(0f, 100f)] private float _vignetteWidth = 50f;
    [SerializeField, Range(0.5f, 3f)] private float _scanlinesMultiplier = 1f;
    [SerializeField] private Vector3 _rgbMultiplier = new(0.25f, 0.2f, 0.3f);
    
    private static readonly int s_crtCurvature = Shader.PropertyToID("_Curvature");
    private static readonly int s_crtVignetteWidth = Shader.PropertyToID("_VignetteWidth");
    private static readonly int s_crtScanlinesMultiplier = Shader.PropertyToID("_ScanlinesMultiplier");
    private static readonly int s_crtRGBMultiplier = Shader.PropertyToID("_RGBMultiplier");
    
    private Material _material;

    private bool InitMaterial()
    {
        if (_shader == null)
            return false;

        if (_material == null)
            _material = new Material(_shader);

        return true;
    }
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!this.InitMaterial())
            return;

        this.UpdateValues();
        Graphics.Blit(source, destination, _material);
    }

    private void OnValidate()
    {
        if (!this.InitMaterial())
            return;
        
        this.UpdateValues();
    }

    private void UpdateValues()
    {
        _material.SetFloat(s_crtCurvature, this._curvature);
        _material.SetFloat(s_crtVignetteWidth, this._vignetteWidth);
        _material.SetFloat(s_crtScanlinesMultiplier, this._scanlinesMultiplier);
        _material.SetVector(s_crtRGBMultiplier, this._rgbMultiplier); 
    }

    private void OnEnable()
    {
        this.InitMaterial();
    }

    private void OnDisable()
    {
        DestroyImmediate(_material);
    }
}
