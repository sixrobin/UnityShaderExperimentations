using UnityEngine;

public class USBSimpleColorController : MonoBehaviour
{
    [SerializeField]
    private ComputeShader _computeShader;
    [SerializeField]
    private Texture _colorTex;
    [SerializeField]
    private RenderTexture _mainTex;
    [SerializeField]
    private Renderer _renderer;

    private int _mainTexTexelSize = 256;

    private void Start()
    {
        this._mainTex = new RenderTexture(this._mainTexTexelSize, this._mainTexTexelSize, 0, RenderTextureFormat.ARGB32)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point
        };
        
        this._mainTex.Create();
        
        this._computeShader.SetTexture(0, "Result", this._mainTex);
        this._computeShader.SetTexture(0, "ColorTex", this._colorTex);
        
        this._renderer.material.SetTexture("_MainTex", this._mainTex);
        
        this._computeShader.Dispatch(0, this._mainTexTexelSize / 8, this._mainTexTexelSize / 8, 1);
    }
}
