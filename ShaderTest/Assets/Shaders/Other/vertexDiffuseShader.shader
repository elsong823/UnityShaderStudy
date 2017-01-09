Shader "MyShader/c6/vertexDiffuse"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
	}	
	SubShader
	{
		Pass
		{
			Tags{ "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);

				//calc light
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 diffuse = fixed3(0.0, 0.0, 0.0);

				fixed3 worldNormal = normalize( mul(i.normal, (float3x3)_World2Object) );
				fixed3 worldLight = normalize( _WorldSpaceLightPos0.xyz );
				diffuse = _LightColor0 * _Diffuse * saturate(dot(worldNormal, worldLight));
				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(in v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"

}