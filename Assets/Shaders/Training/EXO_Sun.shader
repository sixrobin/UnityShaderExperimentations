Shader "EXO/EXO_Sun"
{
    Properties
    {
        [Header(MAIN COLOR)]
        [Space(5)]
        _MainTex ("Texture", 2D) = "white" {}
        _ColorRamp ("Color Ramp", 2D) = "white" {}
        _ColorRampSpeed ("Color Ramp Speed", Range(0, 10)) = 1
                    
        [Space(15)]

        [Header(DISPLACEMENT)]
        [Space(5)]
        _DisplacementAmount ("Displacement Amount", Range(0, 1)) = 1
        _DisplacementSpeed ("Displacement Speed", Range(0, 10)) = 1
        _DisplacementWaves ("Displacement Waves", Range(1, 10)) = 1
        
        [Space(15)]

        [Header(FRESNEL)]
        [Space(5)]
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelWidth ("Fresnel Width", Range(0, 20)) = 1
        _FresnelSharpness ("Fresnel Sharpness", Range(1, 20)) = 1
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
            #define TAU 6.2831853071

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_ramp : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_ramp : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ColorRamp;
            float4 _ColorRamp_ST;
            float _ColorRampSpeed;

            // Inflate.
            float _DisplacementAmount;
            float _DisplacementSpeed;
            float _DisplacementWaves;
            
            // Fresnel.
            float4 _FresnelColor;
            float _FresnelWidth;
            float _FresnelSharpness;
            
            v2f vert(appdata v)
            {
                v2f o;
                
                o.vertex = v.vertex;

                o.vertex.x += cos((v.uv.x * _DisplacementWaves - _Time.y * _DisplacementSpeed) * TAU) * _DisplacementAmount;
                o.vertex.y += cos((v.uv.y * _DisplacementWaves - _Time.y * _DisplacementSpeed) * TAU) * _DisplacementAmount;
                
                o.vertex = UnityObjectToClipPos(o.vertex);
                
                const float3 view_dir = normalize(ObjSpaceViewDir(v.vertex));
                const float dot_product = 1 - dot(v.normal, view_dir);
                o.color = pow(smoothstep(1 - _FresnelWidth, 1.0, dot_product), _FresnelSharpness) * _FresnelColor;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_ramp = TRANSFORM_TEX(v.uv, _ColorRamp);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 ramp = tex2D(_ColorRamp, float2(col.r + _Time.y * _ColorRampSpeed, _Time.y * _ColorRampSpeed));

                ramp.rgb += i.color;
                
                return fixed4(ramp.rgb, 1);
            }
            
            ENDCG
        }
    }
}