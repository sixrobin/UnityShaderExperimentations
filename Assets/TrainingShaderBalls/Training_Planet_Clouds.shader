Shader "Training/Planet Clouds"
{
    Properties
    {
        _CloudsTex ("Clouds Map", 2D) = "white" {}
        _CloudsAttenuation ("Clouds Attenuation", Range(0, 1)) = 0.5
        _CloudsSpeed ("Clouds Speed", Range(-10, 10)) = 1
        _CapsFadePercentage ("Caps Fade %", Range(0, 1)) = 0.3
        _CapsFadeSmooth ("Caps Fade Smooth", Range(0, 0.5)) = 0.2
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        Blend OneMinusDstColor One
        Cull Off
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _CloudsTex;
            float4 _CloudsTex_ST;
            float _CloudsAttenuation;
            float _CloudsSpeed;
            float _CapsFadePercentage;
            float _CapsFadeSmooth;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _CloudsTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv.x += _Time * _CloudsSpeed;
                
                fixed4 clouds_map = tex2D(_CloudsTex, i.uv);
                clouds_map -= _CloudsAttenuation;
                clouds_map = saturate(clouds_map);

                float fade_percentage = _CapsFadePercentage * 0.5;

                float fade_bottom = (1 - smoothstep(i.uv.y - _CapsFadeSmooth, i.uv.y + _CapsFadeSmooth, fade_percentage));
                float fade_top = smoothstep(abs(-i.uv.y) - _CapsFadeSmooth, abs(-i.uv.y) + _CapsFadeSmooth, (1 - fade_percentage));
                float fade = fade_bottom * fade_top;
                
                return fixed4(clouds_map.rgb * fade, 1);
            }
            ENDCG
        }
    }
}