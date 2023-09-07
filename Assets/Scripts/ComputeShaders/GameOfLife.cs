using UnityEngine;

public class GameOfLife : MonoBehaviour
{
    [SerializeField]
    private ComputeShader _randomComputeShader;
    [SerializeField]
    private ComputeShader _gameOfLifeComputeShader;
    [SerializeField]
    private Renderer _renderer;

    [SerializeField, Min(32)]
    private int _resolution = 32;
    [SerializeField, Min(0.01f)]
    private float _iterationDelay = 0.1f;

    [SerializeField]
    private uint _iterations = 0;

    private RenderTexture _grid;
    private RenderTexture _gridBuffer;
    private float _timer;

    private void Iterate()
    {
        this._gameOfLifeComputeShader.SetTexture(0, "Result", this._grid);
        this._gameOfLifeComputeShader.SetTexture(0, "GridBuffer", this._gridBuffer);
        this._gameOfLifeComputeShader.Dispatch(0, this._resolution / 8, this._resolution / 8, 1);
        
        this._gameOfLifeComputeShader.SetTexture(1, "Result", this._gridBuffer);
        this._gameOfLifeComputeShader.SetTexture(1, "GridBuffer", this._grid);
        this._gameOfLifeComputeShader.Dispatch(1, this._resolution / 8, this._resolution / 8, 1);
    }
    
    private void Start()
    {
        this._grid = new RenderTexture(this._resolution, this._resolution, 0, RenderTextureFormat.ARGB32)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point
        };
        
        this._gridBuffer = new RenderTexture(this._resolution, this._resolution, 0, RenderTextureFormat.ARGB32)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point
        };
        
        this._grid.Create();
        this._gridBuffer.Create();
        
        this._gameOfLifeComputeShader.SetFloat("Resolution", this._resolution);

        this._renderer.material.SetTexture("_MainTex", this._grid);

        this._randomComputeShader.SetTexture(0, "Result", this._gridBuffer);
        this._randomComputeShader.Dispatch(0, this._resolution / 8, this._resolution / 8, 1);

        this._gameOfLifeComputeShader.SetTexture(1, "Result", this._grid);
        this._gameOfLifeComputeShader.SetTexture(1, "GridBuffer", this._gridBuffer);
        this._gameOfLifeComputeShader.Dispatch(1, this._resolution / 8, this._resolution / 8, 1);
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
