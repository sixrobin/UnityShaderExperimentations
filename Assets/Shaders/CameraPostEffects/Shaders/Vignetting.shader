// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Vignetting" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_vignette("Vignette Strength", float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
						
	uniform sampler2D _MainTex;
	float _vignette;
			
	struct appdata_t
    {
        float4 vertex	: POSITION;
        fixed4 color	: COLOR;
        half2 uv		: TEXCOORD0;
    };
 
    struct v2f
    {
        float4 vertex   : SV_POSITION;
        fixed4 color    : COLOR;
		half2 uv		: TEXCOORD0;
    };   
             
  	v2f vert(appdata_t i)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(i.vertex);
        o.uv = i.uv;
        o.color = i.color;               
        return o;
    }

	fixed4 frag (v2f i) : SV_Target
	{
		float2 uv = i.uv.xy;

		float4 sum = (float4)0;
		sum = tex2D(_MainTex, float2(uv.x, uv.y));

		float3 vg = (float3)0;
		vg.rgb = sum.xyz;
	
		vg.r += 0.033 * sum.x;
		vg.g += 0.033 * sum.y;
		vg.b += 0.033 * sum.z;
		vg = clamp(vg * 0.6 + 0.4 * vg * vg, 0.08, 1.0);
	
		float vignette = (float)0;
		vignette = (10.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
		vg *= pow(vignette, _vignette);

		return fixed4(vg, 1.0);
	}			
	
	ENDCG

	Subshader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		}
	}
	Fallback off
}
