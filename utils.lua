Utils = {}


function Utils.degToRad(deg) return deg * (math.pi / 180) end


function Utils.offsetVerticle(verts, x, y)
    local v = {}
    for i = 0, table.getn(verts), 0 do
        v[i] = verts[i] + x
        i = i + 1
        v[i] = verts[i] + y
        i = i + 1
    end
    return v
end


function Utils.clipRange(val, min, max)
    if val < min then val = min 
    elseif val > max then val = max
    end
end



function Utils.pointInBoundingBox(box, tx, ty)
    return  (box[2].x >= tx and box[2].y >= ty)
    and (box[1].x <= tx and box[1].y <= ty)
    or  (box[1].x >= tx and box[2].y >= ty)
    and (box[2].x <= tx and box[1].y <= ty)
end

