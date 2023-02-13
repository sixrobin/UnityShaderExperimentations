using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ProceduralTunnel : MonoBehaviour
{
    [SerializeField] private float _radius = 0.5f;
    [SerializeField] private float _length = 3f;

    private Mesh _mesh;
    
    private void OnEnable()
    {
        this._mesh = new Mesh
        {
            name = "Procedural Tunnel Mesh"
        };
        
        this.RefreshVertices();

        this._mesh.triangles = new[]
        {
            0,2,1,
            1,2,3,
            2,4,3,
            3,4,5,
            4,6,5,
            5,6,7
        };
        
        this._mesh.normals = new[]
        {
            Vector3.back,
            Vector3.back,
            (Vector3.back + Vector3.up).normalized,
            (Vector3.back + Vector3.up).normalized,
            (Vector3.forward + Vector3.up).normalized,
            (Vector3.forward + Vector3.up).normalized,
            Vector3.forward,
            Vector3.forward
        };

        this.RefreshUV();
        
        this._mesh.tangents = new[]
        {
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
            new Vector4(1f, 0f, 0f, -1f),
        };
        
        this.GetComponent<MeshFilter>().mesh = this._mesh;
    }

    private void RefreshVertices()
    {
        float l = this._length;
        float r = this._radius * 2f;
        
        Vector3 offset = -Vector3.one * 0.5f;
        offset.x *= l;
        offset.y *= r;
        offset.z *= r;
        
        this._mesh.vertices = new[]
        {
            new Vector3(0, 0, 0) + offset,
            new Vector3(l, 0, 0) + offset,
            new Vector3(0, r, 0) + offset,
            new Vector3(l, r, 0) + offset,
            new Vector3(0, r, r) + offset,
            new Vector3(l, r, r) + offset,
            new Vector3(0, 0, r) + offset,
            new Vector3(l, 0, r) + offset,
        };
    }

    private void RefreshUV()
    {
        float l = this._length;
        float r = this._radius * 2f;

        Vector2[] uvs = new Vector2[8];
        for (int i = 0; i < 8; ++i)
            uvs[i] = new Vector2((i % 2) * l, Mathf.Floor(i * 0.5f) * r);

        this._mesh.uv = uvs;

        // this._mesh.uv = new[]
        // {
        //     new Vector2(0, r * 0),
        //     new Vector2(l, r * 0),
        //     new Vector2(0, r * 1),
        //     new Vector2(l, r * 1),
        //     new Vector2(0, r * 2),
        //     new Vector2(l, r * 2),
        //     new Vector2(0, r * 3),
        //     new Vector2(l, r * 3)
        // };
    }
    
    private void OnValidate()
    {
        if (this._mesh == null)
            return;

        this.RefreshVertices();
        this.RefreshUV();
    }
}
