// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/DualTone" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_volume("Volumic Color", float) = 0
		_global("Global Illumination", float) = 0
		_threshold("Threshold", float) = 0.5
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float4 _volume;
	float4 _global;
	float _threshold;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float4 sum = (float4)0;
	    sum = tex2D(_MainTex, i.uv);

		sum.rgb = (sum.r + sum.g + sum.b) / 3;

		if (sum.r < _threshold || sum.r > 1)
			sum.r = _volume.r;
		else
			sum.r = _global.r;

		if (sum.g < _threshold || sum.g > 1)
			sum.g = _volume.g;
		else
			sum.g = _global.g;

		if (sum.b < _threshold || sum.b > 1)
			sum.b = _volume.b;
		else
			sum.b = _global.b;
#ifdef INVERT
			return (1 - sum);
#else
			return fixed4(sum);
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
