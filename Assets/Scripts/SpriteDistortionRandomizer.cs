using UnityEngine;

public class SpriteDistortionRandomizer : MonoBehaviour
{
    [SerializeField] private Vector2 _randomRange = new(0f, 1f);

    private static readonly int DistortionTimeOffset = Shader.PropertyToID("_DistortionTimeOffset");

    private Renderer _renderer;
    private MaterialPropertyBlock _propertyBlock;

    private void Awake()
    {
        this._renderer = this.GetComponent<Renderer>();
        this._propertyBlock = new MaterialPropertyBlock();
        
        this._renderer.GetPropertyBlock(this._propertyBlock);
        this._propertyBlock.SetFloat(DistortionTimeOffset, Random.Range(this._randomRange.x, this._randomRange.y));
        this._renderer.SetPropertyBlock(this._propertyBlock);
    }
}