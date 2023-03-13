// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/ColoredStripe" {
	
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_threshold("Threshold", float) = 1
		_size("Dot Size", float) = 0.5
		_shape("Shape FX", int) = 0
		_resX("ResolutionX", int) = 1280
		_resY("ResolutionY", int) = 720
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _threshold;
	float _size;
	int _shape;
	int _resX;
	int _resY;

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
		sum = -4 * tex2D(_MainTex, i.uv);

		float2 offsets[9] = 
		{  
			float2(-1, -1),
			float2(-1, 0),
			float2(-1, 1),
			float2(0, -1),
			float2(0, 0),  
			float2(0, 1),  
			float2(1, -1),
			float2(1, 0),
			float2(1, 1)
		}; 

		for (int j = 0; j < 9; j++)
			sum += tex2D(_MainTex, i.uv + 0.001 * offsets[j]);

		if (_shape == 0)
			sum.rgb += cos(i.uv.y * _resX * _size) * _threshold;

		if (_shape == 1)
			sum.rgb += cos(i.uv.x * _resY * _size) * _threshold;

		if (_shape == 2)
		{
			sum.rgb += cos(i.uv.x * _resX * _size) * _threshold;
			sum.rgb += cos(i.uv.y * _resY * _size) * _threshold;
		}

		sum.rgb *= dot(sum.xyz * sum.rgb, 0.5);

#ifdef INVERT
		sum = 1 - sum;
#endif
		return fixed4(sum); 
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
