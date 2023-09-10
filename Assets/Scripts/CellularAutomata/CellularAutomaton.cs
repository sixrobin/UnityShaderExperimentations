using UnityEngine;

public abstract class CellularAutomaton : MonoBehaviour
{
    [SerializeField]
    protected ComputeShader _computeShader;
    [SerializeField]
    private Renderer _renderer;
    
    [SerializeField, Min(32)]
    private E_Resolution _resolution = E_Resolution._128;
    [SerializeField]
    private TextureWrapMode _wrapMode = TextureWrapMode.Repeat;

    [SerializeField, Min(0f)]
    private float _iterationDelay = 0.01f;
    
    [SerializeField, Min(0.001f), Range(0f, 1f)]
    private float _decayStep = 0.1f;
    [SerializeField]
    private Gradient _gradient;
    
    private static readonly int MAIN_TEX_SHADER_ID = Shader.PropertyToID("_MainTex");
    private static readonly int RAMP_SHADER_ID = Shader.PropertyToID("_Ramp");
    
    protected RenderTexture _grid;
    protected RenderTexture _gridBuffer;
    private float _timer;
    private Texture2D _ramp;

    private enum E_Resolution
    {
        [InspectorName("8")]     _8 = 8,
        [InspectorName("16")]    _16 = 16,
        [InspectorName("32")]    _32 = 32,
        [InspectorName("64")]    _64 = 64,
        [InspectorName("128")]   _128 = 128,
        [InspectorName("256")]   _256 = 256,
        [InspectorName("512")]   _512 = 512,
        [InspectorName("1024")]  _1024 = 1024,
        [InspectorName("2048")]  _2048 = 2048,
        [InspectorName("4096")]  _4096 = 4096,
        [InspectorName("8192")]  _8192 = 8192,
        [InspectorName("16384")] _16384 = 16384,
    }
    
    public int Resolution => (int)this._resolution;
    
    protected virtual void Init()
    {
        this._grid = new RenderTexture(this.Resolution, this.Resolution, 0, RenderTextureFormat.ARGB32)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point,
            wrapMode = this._wrapMode,
        };
        
        this._gridBuffer = new RenderTexture(this.Resolution, this.Resolution, 0, RenderTextureFormat.ARGB32)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point,
            wrapMode = this._wrapMode,
        };
        
        this._grid.Create();
        this._gridBuffer.Create();

        // Create a compute shader copy so that every instance can have its own parameters.
        this._computeShader = Instantiate(this._computeShader);
        
        this._computeShader.SetFloat("Resolution", this.Resolution);
        this._computeShader.SetFloat("DecayStep", this._decayStep);
        
        this.InitRampTexture();
        
        this._renderer.material.SetTexture(MAIN_TEX_SHADER_ID, this._grid);
    }
    
    protected abstract void Next();

    protected virtual void ApplyTextureBuffer()
    {
        this._computeShader.SetTexture(2, "Result", this._gridBuffer);
        this._computeShader.SetTexture(2, "GridBuffer", this._grid);
        this._computeShader.Dispatch(2, this.Resolution / 8, this.Resolution / 8, 1);
    }

    private void InitRampTexture()
    {
        this._ramp = new Texture2D(32, 1, TextureFormat.RGBAFloat, false)
        {
            wrapMode = TextureWrapMode.Clamp,
            filterMode = FilterMode.Point,
        };
        
        for (int x = 0; x < this._ramp.width; ++x)
            this._ramp.SetPixel(x, 0, this._gradient.Evaluate(x / (float)this._ramp.width));
        
        this._ramp.Apply();
        this._renderer.material.SetTexture(RAMP_SHADER_ID, this._ramp);
    }
    
    #region UNITY FUNCTIONS
    private void Start()
    {
        this.Init();
    }

    private void Update()
    {
        this._timer += Time.deltaTime;
        if (this._timer > this._iterationDelay)
        {
            this.Next();
            this._timer = 0f;
        }
    }
    #endregion // UNITY FUNCTIONS
}
