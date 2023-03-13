using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]

public class Scratch : MonoBehaviour
{
    Texture2D _scalar;
    public bool _colored = false;

    Camera cam;

    string[] scratch = new string[]
    {
        "0000 0000 0000 0000 0000 0100 0101 0101 0101 0101 0101 0101 0111 0111 1111 1111",
        "0100 0100 1010 1010 1010 1010 1010 1010 1010 1010 1011 1111 1111 1111 1111 1111",
        "0000 0000 0000 0000 0001 0001 0001 0101 0101 0101 0101 0101 0101 1101 1101 1111",
        "0000 0010 0010 1010 1010 1010 1010 1010 1011 1111 1111 1111 1111 1111 1111 1111"
    };

    int width = 64;
    int height = 4;

    private Shader scratchShader = null;
    private Material scratchMaterial = null;
    bool isSupported = true;

    void Awake()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        scratchShader = Shader.Find("MyShaders/Scratch");
        scratchMaterial = CheckShader(scratchShader, scratchMaterial);

        return isSupported;
    }

    protected Material CheckShader(Shader s, Material m)
    {
        if (s == null)
        {
            Debug.Log("Missing shader in " + ToString());
            this.enabled = false;
            return null;
        }

        if (s.isSupported == false)
        {
            Debug.Log("The shader " + s.ToString() + " is not supported on this platform");
            this.enabled = false;
            return null;
        }

        if (s.isSupported && m && m.shader == s)
            return m;

        m = new Material(s);
        m.hideFlags = HideFlags.DontSave;

        cam = GetComponent<Camera>();
        cam.renderingPath = RenderingPath.UsePlayerSettings;

        return m;
    }

    void Start()
    {
        _scalar = new Texture2D(width, height, TextureFormat.ARGB32, false);

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                scratch[j] = scratch[j].Replace(" ", "");

                if (scratch[j].Substring(i, 1) == "1")
                    _scalar.SetPixel(i, j, Color.white);
                else
                    _scalar.SetPixel(i, j, Color.black);
            }
        }

        _scalar.Apply();
    }

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(scratchMaterial);
#else
        Destroy(scratchMaterial);
#endif
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        float w = Screen.width;
        float h = Screen.height;
        Vector2 _count = new Vector2(w / _scalar.height, h / _scalar.height);

        scratchMaterial.SetVector("_count", _count);
        scratchMaterial.SetTexture("_scalar", _scalar);
        scratchMaterial.SetInt("_ratio", width / height);

        if (_colored == true)
            scratchMaterial.EnableKeyword("COLORED");
        else
            scratchMaterial.DisableKeyword("COLORED");

        Graphics.Blit(source, destination, scratchMaterial);
    }
}
