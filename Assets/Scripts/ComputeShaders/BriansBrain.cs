public class BriansBrain : CellularAutomaton
{
    protected override void Init()
    {
        base.Init();
        
        this._computeShader.SetTexture(0, "Result", this._gridBuffer);
        this._computeShader.Dispatch(0, this._resolution / 8, this._resolution / 8, 1);

        this._computeShader.SetTexture(2, "Result", this._grid);
        this._computeShader.SetTexture(2, "GridBuffer", this._gridBuffer);
        this._computeShader.Dispatch(2, this._resolution / 8, this._resolution / 8, 1);
    }

    protected override void Next()
    {
        this._computeShader.SetTexture(1, "Result", this._grid);
        this._computeShader.SetTexture(1, "GridBuffer", this._gridBuffer);
        this._computeShader.Dispatch(1, this._resolution / 8, this._resolution / 8, 1);
        
        this.ApplyTextureBuffer();
    }
}
