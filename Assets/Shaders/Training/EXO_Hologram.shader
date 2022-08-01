Shader "EXO/EXO_Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(LINES)]
        [Space(5)]
        _LinesColor ("Lines Color", Color) = (1,1,1,1)
        _LinesSections ("Lines Sections", Range(2, 50)) = 10
        _LinesSpeed ("Lines Speed", Range(0.1, 10)) = 1
        
        [Header(SCAN)]
        [Space(5)]
        _ScanColor ("Scan Color", Color) = (1,1,1,1)
        _ScanSections ("Scan Sections", Range(1, 10)) = 1
        _ScanSpeed ("Scan Speed", Range(0.1, 10)) = 1
        
        [Header(FRESNEL)]
        [Space(5)]
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelWidth ("Fresnel Width", Range(0, 20)) = 1
        
        [Header(BLEND)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _ScrBlend ("Source Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Source Blend", float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        Blend [_ScrBlend] [_DstBlend]
        Cull back
        Lighting Off
        ZWrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // Lines.
            float4 _LinesColor;
            float _LinesSections;
            float _LinesSpeed;

            // Scan.
            float4 _ScanColor;
            float _ScanSections;
            float _ScanSpeed;

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
                // Main tex color.
                fixed4 main_color = tex2D(_MainTex, i.uv);

                // Fresnel.
                main_color.rgb += i.color;
                
                // Lines.
                float4 lines_color = tan((i.uv.y - (_Time.y * _LinesSpeed)) * _LinesSections);
                lines_color *= _LinesColor;

                // Scan.
                float4 scan_color = tan((i.uv.y - (_Time.y * _ScanSpeed)) * _ScanSections);
                scan_color *= _ScanColor;

                // Final computation.
                float4 hologram = saturate(main_color * lines_color + scan_color);
                hologram.rgb += i.color;
                
                return hologram;
            }
            
            ENDCG
        }
    }
}