function [y, w] = processHearinglosseq(x, filt, ch)

[y,w] = filter([filt.a0, filt.a1, filt.a2], [filt.b0, filt.b1, filt.b2],x,filt.w(:,ch));

