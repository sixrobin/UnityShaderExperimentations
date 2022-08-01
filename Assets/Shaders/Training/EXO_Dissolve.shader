Shader "EXO/EXO_Dissolve"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        
        [Header(DISSOLVE)]
        [Space(5)]
        _DissolveTex ("Dissolve Texture", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0
        _DissolveColor ("Dissolve Color", Color) = (1, 1, 1, 1)
        _DissolveWidth ("Dissolve Width", Range(0, 0.1)) = 0.1
        _DissolveSmooth ("Dissolve Smooth", Range(0, 0.1)) = 0.1
        
        [Header(MOTION)]
        [Space(5)]
        _Speed ("Speed", Range(0, 20)) = 0
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_DissolveTex : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_DissolveTex : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;
            
            half _DissolveAmount;
            half4 _DissolveColor;
            half _DissolveWidth;
            half _DissolveSmooth;

            float _Speed;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_MainTex = TRANSFORM_TEX(v.uv_MainTex, _MainTex);
                o.uv_DissolveTex = TRANSFORM_TEX(v.uv_MainTex, _DissolveTex);

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                _DissolveAmount = (sin(_Time.y * _Speed) + 1) * 0.5;
                
                const half dissolve_value = tex2D(_DissolveTex, i.uv_DissolveTex).r; // RBG are the same on a B&W texture.
                clip(dissolve_value - _DissolveAmount);

                fixed4 main_color = tex2D(_MainTex, i.uv_MainTex);
                
                // Unlit highlight.
                fixed3 highlight = smoothstep(dissolve_value - _DissolveAmount - _DissolveSmooth, dissolve_value - _DissolveAmount + _DissolveSmooth, _DissolveWidth);
                main_color.xyz = lerp(main_color, _DissolveColor.xyz, highlight);

                // // Additive highlight.
                // fixed3 highlight = _DissolveColor * smoothstep(dissolve_value - _DissolveAmount - _DissolveSmooth, dissolve_value - _DissolveAmount + _DissolveSmooth, _DissolveWidth);
                // main_color.xyz += highlight;
                
                return main_color;
            }
            
            ENDCG
        }
    }
    
    Fallback "Diffuse"
}