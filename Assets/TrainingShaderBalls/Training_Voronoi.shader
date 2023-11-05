Shader "Training/Voronoi"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(VORONOI)]
        [Space(5)]
        _AngleOffset ("Angle Offset", Range(0, 360)) = 0
        _CellDensity ("Cell Density", Range(1, 100)) = 1
        [IntRange] _Sharpness ("Sharpness", Range(1, 10)) = 1
        _AngleOffsetSpeed ("Angle Offset Speed", Range(0, 10)) = 0

        [Header(COLOR)]
        [Space(5)]
        _CellsColor ("Cells Color", Color) = (1,1,1,1)
        _VeinsColorA ("Veins Color A", Color) = (0,0,0,1)
        _VeinsColorB ("Veins Color B", Color) = (0,0,0,1)
        _VeinsPulseSpeed ("Veins Pulse Speed", Range(1, 10)) = 5
        
        [Header(FRESNEL)]
        [Space(5)]
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelWidth ("Fresnel Width", Range(0, 20)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : COLOR;
            };

            inline float2 voronoi_noise_random_vector(float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)) * 46839.32);
                return float2(sin(UV.y * offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
            }

            void voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float3 res = float3(8.0, 0.0, 0.0);

                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 lattice = float2(x, y);
                        float2 offset = voronoi_noise_random_vector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if (d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // Voronoi.
            float _AngleOffset;
            float _CellDensity;
            float _Sharpness;
            
            // Colors.
            float4 _CellsColor;
            float4 _VeinsColorA;
            float4 _VeinsColorB;
            float _VeinsPulseSpeed;
            float _AngleOffsetSpeed;

            // Fresnel.
            float4 _FresnelColor;
            float _FresnelWidth;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                const float3 view_dir = normalize(ObjSpaceViewDir(v.vertex));
                const float dot_product = 1 - dot(v.normal, view_dir);
                o.color = smoothstep(1 - _FresnelWidth, 1.0, dot_product) * _FresnelColor;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Voronoi noise.
                float angle_offset_time = _Time.y * _AngleOffsetSpeed;
                float voronoi_out = 0;
                float voronoi_cells = 0;
                voronoi_float(i.uv, _AngleOffset + angle_offset_time, _CellDensity, voronoi_out, voronoi_cells);

                voronoi_out = pow(voronoi_out, _Sharpness); // Sharpen voronoi.
                
                // Veins color.
                float4 veinsColor = lerp(_VeinsColorA, _VeinsColorB, sin(_Time.y * _VeinsPulseSpeed));

                // Voronoi colored.
                float4 voronoi_colored = lerp(_CellsColor, veinsColor, voronoi_out);

                // Fresnel.
                voronoi_colored.rgb += i.color;
                
                return voronoi_colored;
            }
            
            ENDCG
        }
    }
}