# Cool-chic

You can check system for using Pytorch
python Check_System_Pytorch.py


#Encoding test command
python3 samples/encode.py -i /app/Cool-Chic/test/data/kodim15_192x128_01p_yuv420_8b.yuv -o kodim15_192x128_01p_yuv420_8b.cool

#decoding test command
python coolchic/decode.py -i samples/bitstreams/a365_wd.cool -o a365_wd.ppm 
