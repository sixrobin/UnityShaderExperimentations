// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/ThermalVision" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_shadow("Shadow Color", float) = 0
		_volume("Volumic Color", float) = 0
		_global("Global Illumination", float) = 0
		_threshold("Threshold", float) = 0
		_invert("Negative", float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float3 _shadow;
	float3 _volume;
	float3 _global;
	float _threshold;
	float _invert;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float3 colored = tex2D(_MainTex, i.uv).rgb;

		float3 colors[3] = 
		{
			_shadow,
			_volume,
			_global
		};

		float litColor = (colored.r + colored.g + colored.b) / 3; 
		int threshold = (litColor < _threshold)? 0:1;
		float3 sum = lerp(colors[threshold], colors[threshold + 1], (litColor-float(threshold) * 0.5f) / 0.5f);
		 
#ifdef INVERT
			return fixed4(1 - sum, 1);
#else
			return fixed4(sum, 1);
#endif
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
			#pragma shader_feature INVERT
			ENDCG
		} 
	}
	Fallback off	
}
