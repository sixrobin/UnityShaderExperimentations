using UnityEngine;

[ExecuteInEditMode]
public class Inverted : MonoBehaviour
{
    [SerializeField] private Shader _shader = null;

    [SerializeField, Range(0f, 1f)] public float _percentage = 0f;
    
    private static readonly int PercentageID = Shader.PropertyToID("_Percentage");
    
    private Material _material;

    public float Percentage
    {
        get => _percentage;
        set => _percentage = Mathf.Clamp01(value);
    }

    public void SetInverted(bool inverted)
    {
        Percentage = inverted ? 1f : 0f;
    }
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_shader == null)
        {
            _shader = Shader.Find("RSLib/Inverted");
            if (_shader == null)
                return;
        }

        if (_material == null)
            _material = new Material(_shader);

        _material.SetFloat(PercentageID, _percentage);

        Graphics.Blit(source, destination, _material);
    }
}
