using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ProceduralQuad : MonoBehaviour
{
    [SerializeField] private float _width = 1f;
    [SerializeField] private float _height = 1f;
    
    private Mesh _mesh;
    
    private void OnEnable()
    {
        this._mesh = new Mesh
        {
            name = "Procedural Quad Mesh"
        };

        this.RefreshVertices();

        this._mesh.triangles = new[]
        {
            0,2,1,
            1,2,3
        };
        
        this._mesh.normals = new[]
        {
            Vector3.back,
            Vector3.back,
            Vector3.back,
            Vector3.back
        };

        this._mesh.uv = new[]
        {
            Vector2.zero,
            Vector2.right,
            Vector2.up,
            Vector2.one
        };
        
        this._mesh.tangents = new[]
        {
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
        };
        
        this.GetComponent<MeshFilter>().mesh = this._mesh;
    }

    private void RefreshVertices()
    {
        float w = this._width;
        float h = this._height;
        
        this._mesh.vertices = new Vector3[]
        {
            new(0, 0, 0),
            new(w, 0, 0),
            new(0, h, 0),
            new(w, h, 0)
        };
    }
    
    private void OnValidate()
    {
        if (this._mesh == null)
            return;

        this.RefreshVertices();
    }
}
