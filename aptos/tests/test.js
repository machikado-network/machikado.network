const result = await window.aptos.connect()


var module_hex = "a11ceb0b050000000d01001002103603468b0104d1011e05ef01f40207e304c20408a5094006e509780add0a480ba50b040ca90be1090d8a151a0ea415080000010101020103010401050106010700080701000000090600000a0700000b0800000c0700000d0800000e0600051007000612040203010001031807010000022604010601000f0001000011020100001303010000140401000015050100001606010000170701000019080900001a0a0b00001b0c0100001c0c010005280e0f000429061000012a111100032b13140100032c13150100072d17180100052e1a0f00052f1b110005301b1c0006312014020300013211110002330625010603341829010003350129010002362b0101060e120f121016141f16241626172818281712181219240e280f281022192602060c0a02000208070807020807070b08020807080204080708070807060a080204080708070807060a080401060c04060c0a020a020a0202060a08020807010b09010b0001080202060a08040807010b09010b0001080403060c0a020508070a080408070508070708050b09010b00010804060b00010804070a0804010a0201080701050103010b0001080401060b0901090001010106090001080402070a0900030109000701010101060203060a020306080703030106080701060a02010202070b0802080708020807020807080202060b080209000901090002030608020108020203060804010801010b0a0109000108060b080708070807070a0804050807080708070708050804070a0804010b00010802010b090109000e070a08040807080708070807070a08020508070708030708050b09010b00010804060b00010804070a0804070a080202070b0a010900090008070a080208070108070708030b09010b00010802060b00010802070a080207504b546f6b656e056572726f72056576656e74066f7074696f6e067369676e657206737472696e67057461626c6506766563746f72084e7468546f6b656e0c5075626c6973684576656e740e5075626c6973686564546f6b656e135075626c6973686564546f6b656e53746f726505546f6b656e0a546f6b656e53746f72650e556e7075626c6973684576656e740a6275726e5f746f6b656e06537472696e670b636865636b5f6669656c64055461626c6515636865636b5f7075626c69736865645f746f6b656e1b636865636b5f7075626c69736865645f746f6b656e5f6974656d7311636865636b5f746f6b656e5f6974656d731c6372656174655f7075626c69736865645f746f6b656e5f73746f72650c6372656174655f746f6b656e064f7074696f6e136765745f7075626c69736865645f746f6b656e096765745f746f6b656e077075626c69736809756e7075626c6973680464617461036e74680269640a69705f616464726573730a7075626c69635f6b65790763726561746f72046e616d6506746f6b656e730e7075626c6973685f6576656e74730b4576656e7448616e646c6512756e7075626c69736865645f6576656e747304757466380a616464726573735f6f66096e6f745f666f756e640769735f736f6d6506626f72726f770672656d6f76650a7375625f737472696e67066c656e67746805627974657308636f6e7461696e730e616c72656164795f657869737473106e65775f6576656e745f68616e646c6504736f6d65046e6f6e650a656d69745f6576656e748878e00d2cb67d758b4e57551c790f04b4eda469d17c81c915639c42a1f5bdae00000000000000000000000000000000000000000000000000000000000000010308030000000000000003080500000000000000030804000000000000000308060000000000000003080800000000000000030801000000000000000308000000000000000003080900000000000000030802000000000000000308070000000000000003080a000000000000000a02070631302e35302e0002021d09001e030102011f08070202042008072108072205230807030203240a0802250b0a010801270b0a010806040203200807210807230807050201240a08040602011f08070022001600010401050d2d0b01110b0c050b00110c0c040a042905030c0709110d270b042a050c060b060f000c090a090b050c030c020b022e0b0311080c070e07380003230b09010707110d270e0738010c080b090b08370014380201020100000019610e010600000000000000000606000000000000001111070b110b21030a0700270e0011120620000000000000002503110702270600000000000000000c070e0011130c080a070e00111223031c055e0a080a07421d0c0631300a0614250326052c0a06143139250c02052e090c020b0203310534080c0305390a0614315f210c030b03033c05410b0601080c05055331610a0614250347054d0b0614317a250c0405510b0601090c040b040c050b0503590b08010701270b07060100000000000000160c0705160b080102020000001e0e0b010b000c030c020b022e0b03380320030d07061115270203000000213c0600000000000000000c040a040a03412223030805360a030a0442220c050a051002140a012203190b03010b050107051115270a051003140a022203260b03010b050107081115270b051004140a002203310b030107061115270b04060100000000000000160c0405020b03010b000b0111010204000000233c0600000000000000000c040a040a03411623030805360a030a0442160c050a051005140a012203190b03010b050107051115270a051006140a022203260b03010b050107081115270b051007140a002203310b030107061115270b04060100000000000000160c0405020b03010b000b011101020501040010140a00110c0c010b01290320030805110a00402200000000000000000a0038040b00380512032d0305130b000102060104010527350b01110b0c0a0b02110b0c090b03110b0c0b0a00110c0c080a08290520031105160b004016000000000000000012052d0505180b00010b082a050c0c0b0c0f000c0e0a0a0a090a0b0a0e0c070c060c050c040b040b050b060b072e11040b090b0b0b0a12040c0d0b0e0b0d4416020700000021260600000000000000000c020a020a00412223030805220a000a0242220c030a031004140a01210313051b0b00010b03140b0239003806020b03010b02060100000000000000160c0205020b00013807020800000023260600000000000000000c020a020a00411623030805220a000a0242160c030a031007140a01210313051b0b00010b03140b0239013808020b03010b02060100000000000000160c0205020b00013809020901040203052a600b01110b0c0a0a00110c0c090a092905030e0b00010709110d270b092a050c0c0b0c0f000c0f0b0f0a0a0c040c030b032e0b0411080c0d0e0d380003250b00010707110d270e0d38010c0e0a02290303320b0e010b00010704110d270b022a030c0b0a0b0f080c100a0a0a0e37011005140a0e37011006140a100c080c070c060c050b050b060b070b082e11030b100a0e37011005140b0e37011006140b00110c0a0a120244220b0b0f0a0b0a1201380a020a010401032c510b01110b0c060a022903030b0b00010704110d270a022a030c070a070f080c0a0a0a0a060c040c030b032e0b0411070c080e08380b03250b0a010b07010b00010707270e08380c0c090a093702100b140a00110c21033105360b0001080c05053b0b00110c0b02210c050b0503450b0a010b09010b0701070a270b0a0b09370314380d010b070f0c0b061206380e020500000102000201020304000401040203000000030102020302011609160922012200"

var payload = {
    "type": "module_bundle_payload",
    "modules": [
        {"bytecode": `0x${module_hex}`},
    ],
}