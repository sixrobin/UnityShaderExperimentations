using UnityEngine;

public class BriansBrain : MonoBehaviour
{
    [SerializeField]
    private ComputeShader _computeShader;
    [SerializeField]
    private Renderer _renderer;
    
    [SerializeField, Min(32)]
    private int _resolution = 32;
    [SerializeField, Min(0f)]
    private float _iterationDelay = 0.1f;
    [SerializeField, Min(0.001f), Range(0f, 1f)]
    private float _decayStep = 0.1f;
    [SerializeField]
    private uint _iterations = 0;
    [SerializeField]
    private Gradient _gradient;

    private RenderTexture _grid;
    private RenderTexture _gridBuffer;
    private float _timer;
    private Texture2D _ramp;

    [ContextMenu("Iterate")]
    private void Iterate()
    {
        this._computeShader.SetTexture(1, "Result", this._grid);
        this._computeShader.SetTexture(1, "GridBuffer", this._gridBuffer);
        this._computeShader.Dispatch(1, this._resolution / 8, this._resolution / 8, 1);
        
        this._computeShader.SetTexture(2, "Result", this._gridBuffer);
        this._computeShader.SetTexture(2, "GridBuffer", this._grid);
        this._computeShader.SetFloat("DecayStep", this._decayStep);
        this._computeShader.Dispatch(2, this._resolution / 8, this._resolution / 8, 1);
    }
    
    private void Start()
    {
        this._grid = new RenderTexture(this._resolution, this._resolution, 0, RenderTextureFormat.ARGBFloat)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point
        };
        
        this._gridBuffer = new RenderTexture(this._resolution, this._resolution, 0, RenderTextureFormat.ARGBFloat)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point
        };
        
        this._grid.Create();
        this._gridBuffer.Create();
        
        this._computeShader.SetFloat("Resolution", this._resolution);

        this._computeShader.SetTexture(0, "Result", this._gridBuffer);
        this._computeShader.Dispatch(0, this._resolution / 8, this._resolution / 8, 1);

        this._computeShader.SetTexture(2, "Result", this._grid);
        this._computeShader.SetTexture(2, "GridBuffer", this._gridBuffer);
        this._computeShader.Dispatch(2, this._resolution / 8, this._resolution / 8, 1);

        this._ramp = new Texture2D(32, 1, TextureFormat.RGBAFloat, false)
        {
            wrapMode = TextureWrapMode.Clamp,
            filterMode = FilterMode.Point
        };
        
        for (int x = 0; x < this._ramp.width; ++x)
        {
            Color color = this._gradient.Evaluate(x / (float)this._ramp.width);
            this._ramp.SetPixel(x, 0, color);
        }
        
        this._ramp.Apply();
        
        this._renderer.material.SetTexture("_MainTex", this._grid);
        this._renderer.material.SetTexture("_Ramp", this._ramp);
    }

    private void Update()
    {
        this._timer += Time.deltaTime;
        if (this._timer > this._iterationDelay)
        {
            this.Iterate();
            this._iterations++;
            this._timer = 0f;
        }
    }
}
