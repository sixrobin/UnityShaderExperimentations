using UnityEngine;

[ExecuteInEditMode]
public class InvertedFlash : MonoBehaviour
{
    [SerializeField] private Shader _shader = null;

    [SerializeField, Range(0f, 1f)] public float _percentage = 0f;
    [SerializeField] public bool Desaturated = true;
    [SerializeField] private Vector2 _desaturationSmoothstep = new Vector2(0.45f, 0.55f);
    
    private static readonly int PercentageID = Shader.PropertyToID("_Percentage");
    private static readonly int DesaturateID = Shader.PropertyToID("_Desaturate");
    private static readonly int DesaturationSmoothstepID = Shader.PropertyToID("_DesaturationSmoothstep");
    
    private Material _material;

    public float Percentage
    {
        get => _percentage;
        set => _percentage = Mathf.Clamp01(value);
    }
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_shader == null)
        {
            _shader = Shader.Find("RSLib/InvertedFlash");
            if (_shader == null)
                return;
        }

        if (_material == null)
            _material = new Material(_shader);

        _material.SetFloat(PercentageID, _percentage);
        _material.SetFloat(DesaturateID, this.Desaturated ? 1f : 0f);
        _material.SetVector(DesaturationSmoothstepID, _desaturationSmoothstep);

        Graphics.Blit(source, destination, _material);
    }

    private void OnValidate()
    {
        _desaturationSmoothstep.x = Mathf.Clamp01(_desaturationSmoothstep.x);
        _desaturationSmoothstep.y = Mathf.Clamp01(_desaturationSmoothstep.y);
    }
}
